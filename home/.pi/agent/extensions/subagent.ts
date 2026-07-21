import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import { access, mkdtemp, readdir, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import type { Message } from "@earendil-works/pi-ai";
import {
    CONFIG_DIR_NAME,
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    formatSize,
    getAgentDir,
    keyHint,
    parseFrontmatter,
    truncateHead,
    withFileMutationQueue,
    type ExtensionAPI,
    type ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

type Agent = {
    name: string;
    description: string;
    tools?: string[];
    model?: string;
    systemPrompt: string;
    source: "user" | "project";
};

type Usage = {
    input: number;
    output: number;
    cacheRead: number;
    cacheWrite: number;
    cost: number;
    turns: number;
};

type TruncationDetails = ReturnType<typeof truncateHead> & { fullOutputPath: string };

type Details = {
    agent: string;
    source?: Agent["source"];
    task: string;
    messages: Message[];
    usage: Usage;
    exitCode?: number;
    stderr?: string;
    truncation?: TruncationDetails;
};

const agents = new Map<string, Agent>();

async function loadAgentsFromDir(dir: string, source: Agent["source"]): Promise<Agent[]> {
    const agents: Agent[] = [];
    let entries;

    try {
        entries = await readdir(dir, { withFileTypes: true });
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") return agents;
        throw error;
    }

    for (const entry of entries) {
        if (!entry.name.endsWith(".md") || (!entry.isFile() && !entry.isSymbolicLink())) continue;
        try {
            const content = await readFile(join(dir, entry.name), "utf8");
            const { frontmatter, body } = parseFrontmatter<Record<string, string>>(content);
            if (!frontmatter.name || !frontmatter.description) continue;
            const tools = frontmatter.tools?.split(",").map((tool) => tool.trim()).filter(Boolean);

            agents.push({
                name: frontmatter.name,
                description: frontmatter.description,
                tools: tools?.length ? tools : undefined,
                model: frontmatter.model,
                systemPrompt: body,
                source,
            });
        } catch { }
    }
    return agents;
}

async function loadAgents(ctx: ExtensionContext) {
    agents.clear();

    const userAgents = await loadAgentsFromDir(join(getAgentDir(), "agents"), "user");
    for (const agent of userAgents) agents.set(agent.name, agent);

    if (ctx.isProjectTrusted()) {
        const projectAgents = await loadAgentsFromDir(join(ctx.cwd, CONFIG_DIR_NAME, "agents"), "project");
        for (const agent of projectAgents) agents.set(agent.name, agent);
    }
}

async function piInvocation(args: string[]) {
    const script = process.argv[1];
    if (script && !script.startsWith("/$bunfs/root/")) {
        try {
            await access(script);
            return { command: process.execPath, args: [script, ...args] };
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
        }
    }
    const executable = basename(process.execPath).toLowerCase();
    return /^(node|bun)(\.exe)?$/.test(executable)
        ? { command: "pi", args }
        : { command: process.execPath, args };
}

function finalOutput(messages: Message[]) {
    for (let i = messages.length - 1; i >= 0; i--) {
        const message = messages[i];
        if (message.role !== "assistant") continue;
        const text = message.content.find((part) => part.type === "text");
        if (text?.type === "text") return text.text;
    }
    return "";
}

function errorMessage(error: unknown) {
    return error instanceof Error ? error.message : String(error);
}

function truncationMarker(truncation: TruncationDetails) {
    const warnings = [`Full output: ${truncation.fullOutputPath}`];

    if (truncation.truncatedBy === "lines") {
        warnings.push(`Truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines`);
    } else {
        const limit = formatSize(truncation.maxBytes ?? DEFAULT_MAX_BYTES);
        warnings.push(`Truncated: ${truncation.outputLines} lines shown (${limit} limit)`);
    }

    return `[${warnings.join(". ")}]`;
}

export default function subagent(pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        void loadAgents(ctx);
    });

    pi.registerTool({
        name: "subagent",
        label: "Subagent",
        description: [
            "Run one specialized agent in an isolated Pi process.",
            `Agents come from ${join(getAgentDir(), "agents")} and, only for trusted projects,`,
            `${CONFIG_DIR_NAME}/agents.`,
        ].join(" "),
        promptSnippet: "Delegate one focused task to a specialized agent",
        parameters: Type.Object({
            agent: Type.String({ description: "Agent name" }),
            task: Type.String({ description: "Task to delegate" }),
            cwd: Type.Optional(Type.String({ description: "Working directory; defaults to the current project" })),
        }),

        async execute(_id, params, signal, onUpdate, ctx) {
            const agent = agents.get(params.agent);

            if (!agent) {
                const available = [...agents.values()]
                    .map((candidate) => `${candidate.name} (${candidate.source}): ${candidate.description}`)
                    .join("; ") || "none";

                throw new Error(`Unknown agent "${params.agent}". Available agents: ${available}`);
            }

            const details: Details = {
                agent: agent.name,
                source: agent.source,
                task: params.task,
                messages: [],
                usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 },
                stderr: "",
            };
            const args = ["--mode", "json", "-p", "--no-session"];
            if (agent.model) args.push("--model", agent.model);
            if (agent.tools?.length) args.push("--tools", agent.tools.join(","));

            let promptDir: string | undefined;
            try {
                if (agent.systemPrompt.trim()) {
                    promptDir = await mkdtemp(join(tmpdir(), "pi-subagent-"));
                    const promptPath = join(promptDir, "prompt.md");
                    await withFileMutationQueue(promptPath, () =>
                        writeFile(promptPath, agent.systemPrompt, { encoding: "utf8", mode: 0o600 }),
                    );
                    args.push("--append-system-prompt", promptPath);
                }

                args.push(`Task: ${params.task}`);

                const invocation = await piInvocation(args);
                await new Promise<void>((resolve, reject) => {
                    const child = spawn(invocation.command, invocation.args, {
                        cwd: params.cwd ?? ctx.cwd,
                        shell: false,
                        stdio: ["ignore", "pipe", "pipe"],
                    });
                    let buffer = "";
                    let aborted = false;
                    let killTimer: NodeJS.Timeout | undefined;

                    const update = () =>
                        onUpdate?.({
                            content: [{ type: "text", text: finalOutput(details.messages) || "(running...)" }],
                            details,
                        });
                    const processLine = (line: string) => {
                        if (!line.trim()) return;
                        try {
                            const event = JSON.parse(line);
                            if ((event.type === "message_end" || event.type === "tool_result_end") && event.message) {
                                const message = event.message as Message;
                                details.messages.push(message);

                                if (message.role === "assistant") {
                                    details.usage.turns++;
                                    details.usage.input += message.usage?.input ?? 0;
                                    details.usage.output += message.usage?.output ?? 0;
                                    details.usage.cacheRead += message.usage?.cacheRead ?? 0;
                                    details.usage.cacheWrite += message.usage?.cacheWrite ?? 0;
                                    details.usage.cost += message.usage?.cost?.total ?? 0;
                                }
                                update();
                            }
                        } catch { }
                    };
                    const abort = () => {
                        aborted = true;
                        child.kill("SIGTERM");
                        killTimer = setTimeout(() => child.kill("SIGKILL"), 5000);
                    };

                    child.stdout.on("data", (chunk) => {
                        buffer += chunk.toString();
                        const lines = buffer.split("\n");
                        buffer = lines.pop() ?? "";
                        lines.forEach(processLine);
                    });
                    child.stderr.on("data", (chunk) => {
                        details.stderr += chunk.toString();
                    });
                    child.on("error", reject);
                    child.on("close", (code) => {
                        if (killTimer) clearTimeout(killTimer);
                        signal?.removeEventListener("abort", abort);
                        processLine(buffer);
                        details.exitCode = code ?? 1;

                        if (aborted) reject(new Error("Subagent was aborted"));
                        else resolve();
                    });
                    if (signal?.aborted) abort();
                    else signal?.addEventListener("abort", abort, { once: true });
                });

                const output = finalOutput(details.messages);

                if (details.exitCode !== 0) {
                    throw new Error(details.stderr || output || `Subagent exited with code ${details.exitCode}`);
                }

                if (!output) throw new Error(details.stderr || "Subagent produced no output");

                const truncated = truncateHead(output, {
                    maxBytes: DEFAULT_MAX_BYTES,
                    maxLines: DEFAULT_MAX_LINES,
                });
                let text = truncated.content;

                if (truncated.truncated) {
                    const fullOutputPath = join(tmpdir(), `pi-subagent-${randomBytes(8).toString("hex")}.md`);

                    await withFileMutationQueue(fullOutputPath, () =>
                        writeFile(fullOutputPath, output, { encoding: "utf8", mode: 0o600 }),
                    );

                    details.truncation = { ...truncated, fullOutputPath };
                    text += `\n\n${truncationMarker(details.truncation)}`;
                }

                return { content: [{ type: "text", text }], details };
            } catch (error) {
                throw new Error(`Subagent ${agent.name} failed: ${errorMessage(error)}`);
            } finally {
                if (promptDir) await rm(promptDir, { recursive: true, force: true });
            }
        },

        renderCall(args, theme) {
            const task = args.task.length > 80 ? `${args.task.slice(0, 80)}…` : args.task;
            const title = theme.fg("toolTitle", theme.bold("subagent "));
            const agent = theme.fg("accent", args.agent);

            return new Text(`${title}${agent}\n${theme.fg("dim", task)}`, 0, 0);
        },

        renderResult(result, options, theme) {
            const details = result.details as Details | undefined;
            const truncation = details?.truncation;
            let output = result.content
                .filter((part) => part.type === "text")
                .map((part) => part.text)
                .join("\n");

            if (truncation && output.endsWith("]")) {
                const footerStart = output.lastIndexOf("\n\n[");
                if (footerStart !== -1 && output.slice(footerStart).includes(truncation.fullOutputPath)) {
                    output = output.slice(0, footerStart).trimEnd();
                }
            }

            const renderedOutput = output
                .split("\n")
                .map((line) => theme.fg("toolOutput", line))
                .join("\n");

            return {
                render(width: number) {
                    const lines = renderedOutput ? new Text(renderedOutput, 0, 0).render(width) : [];
                    const displayLines = options.expanded ? lines : lines.slice(0, 10);
                    const remaining = lines.length - displayLines.length;

                    if (remaining > 0) {
                        const hint =
                            theme.fg("muted", `... (${remaining} more lines,`) +
                            ` ${keyHint("app.tools.expand", "to expand")}` +
                            theme.fg("muted", ")");

                        displayLines.push(...new Text(hint, 0, 0).render(width));
                    }

                    if (truncation) {
                        displayLines.push(
                            ...new Text(`\n${theme.fg("warning", truncationMarker(truncation))}`, 0, 0).render(width),
                        );
                    }

                    if (details) {
                        const usage = `${details.usage.turns} turn(s), $${details.usage.cost.toFixed(4)}`;
                        displayLines.push(
                            ...new Text(theme.fg("dim", `${usage}, ${details.source ?? "unknown"}`), 0, 0).render(width),
                        );
                    }

                    return displayLines;
                },
                invalidate() { },
            };
        },
    });
}
