import {
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    defineTool,
    formatSize,
    getAgentDir,
    keyHint,
    truncateHead,
    withFileMutationQueue,
    type AgentToolResult,
    type ExtensionAPI,
    type ExtensionContext,
    type ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { auth, UnauthorizedError, type OAuthClientProvider } from "@modelcontextprotocol/sdk/client/auth.js";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import type { OAuthClientInformationFull, OAuthTokens } from "@modelcontextprotocol/sdk/shared/auth.js";
import {
    CallToolResultSchema,
    type CallToolResult,
    type ContentBlock,
    type Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { randomBytes } from "node:crypto";
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { createServer } from "node:http";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

type ServerConfig = {
    type?: "stdio" | "http";
    command?: string;
    args?: string[];
    env?: Record<string, string>;
    url?: string;
    headers?: Record<string, string>;
    tools?: string[];
    timeout?: number;
    oauth?: {
        clientId?: string;
        clientSecret?: string;
        scope?: string;
        redirectUri?: string;
    };
};

type StoredTokens = {
    accessToken: string;
    refreshToken?: string;
    expiresAt?: number;
    scope?: string;
};

type AuthStore = Record<
    string,
    {
        serverName?: string;
        serverUrl?: string;
        tokens?: StoredTokens;
        clientInformation?: OAuthClientInformationFull;
    }
>;

type Connected = {
    name: string;
    config: ServerConfig;
    client: Client;
    transport: McpTransport;
    tools: Tool[];
};

type McpConfig = { mcpServers?: Record<string, ServerConfig> };
type OAuthServerConfig = ServerConfig & { url: string; oauth: NonNullable<ServerConfig["oauth"]> };
type McpTransport = StdioClientTransport | StreamableHTTPClientTransport;
type McpToolDetails = { truncation: ReturnType<typeof truncateHead>; fullOutputPath: string };
type McpAgentToolResult = AgentToolResult<McpToolDetails | undefined>;
type PiToolContent = McpAgentToolResult["content"];

const DEFAULT_CLIENT_TIMEOUT = 60000;
const OAUTH_CALLBACK_TIMEOUT = 300000;
const connected: Connected[] = [];
const authPath = join(getAgentDir(), "mcp-auth.json");

function expandEnv(s: string) {
    return s.replace(
        /\{env:([A-Z0-9_]+)\}|\$\{([A-Z0-9_]+)\}|\$([A-Z0-9_]+)/gi,
        (_, a, b, c) => process.env[a || b || c] ?? "",
    );
}

function sanitizeName(s: string) {
    return s.replace(/[^a-zA-Z0-9_]/g, "_").replace(/^_+|_+$/g, "") || "mcp";
}

function errorMessage(error: unknown) {
    return error instanceof Error ? error.message : String(error);
}

async function readJson(path: string) {
    try {
        return JSON.parse(await readFile(path, "utf8"));
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") return {};
        throw error;
    }
}

const readAuthStore = async () => (await readJson(authPath)) as AuthStore;

async function writeAuthStore(store: AuthStore) {
    const tempPath = `${authPath}.${process.pid}.${Date.now()}.tmp`;
    await mkdir(dirname(authPath), { recursive: true });
    await writeFile(tempPath, JSON.stringify(store, null, 2), { encoding: "utf8", mode: 0o600 });
    await rename(tempPath, authPath);
}

function authKey(name: string, serverUrl: string) {
    return `${name}|${serverUrl}`;
}

class BrowserOAuthProvider implements OAuthClientProvider {
    private redirect: string;
    private verifier?: string;
    private oauthState = randomBytes(32).toString("hex");

    constructor(
        private name: string,
        private config: OAuthServerConfig,
        private onRedirect?: (url: URL) => void | Promise<void>,
    ) {
        this.redirect = config.oauth.redirectUri ?? "http://127.0.0.1:19876/callback";
    }

    get redirectUrl() {
        return this.redirect;
    }

    async state() {
        return this.oauthState;
    }

    get clientMetadata() {
        return {
            redirect_uris: [this.redirect],
            token_endpoint_auth_method: this.config.oauth.clientSecret ? "client_secret_basic" : "none",
            grant_types: ["authorization_code", "refresh_token"],
            response_types: ["code"],
            client_name: "Pi MCP",
            scope: this.config.oauth.scope,
        };
    }

    async clientInformation() {
        const store = await readAuthStore();
        const serverUrl = this.config.url;
        const saved = store[authKey(this.name, serverUrl)]?.clientInformation;

        if (saved) {
            return saved;
        }

        if (this.config.oauth.clientId) {
            return {
                client_id: this.config.oauth.clientId,
                client_secret: this.config.oauth.clientSecret,
            };
        }
    }

    async saveClientInformation(clientInformation: OAuthClientInformationFull) {
        const store = await readAuthStore();
        const serverUrl = this.config.url;
        const key = authKey(this.name, serverUrl);
        store[key] = {
            ...(store[key] ?? {}),
            serverName: this.name,
            serverUrl,
            clientInformation,
        };
        await writeAuthStore(store);
    }

    async tokens() {
        const store = await readAuthStore();
        const serverUrl = this.config.url;
        const tokens = store[authKey(this.name, serverUrl)]?.tokens;

        if (!tokens) {
            return undefined;
        }

        return {
            access_token: tokens.accessToken,
            token_type: "Bearer",
            refresh_token: tokens.refreshToken,
            expires_in: tokens.expiresAt ? Math.max(0, Math.floor(tokens.expiresAt - Date.now() / 1000)) : undefined,
            scope: tokens.scope,
        };
    }

    async saveTokens(tokens: OAuthTokens) {
        const store = await readAuthStore();
        const serverUrl = this.config.url;
        const key = authKey(this.name, serverUrl);

        store[key] = {
            ...(store[key] ?? {}),
            serverName: this.name,
            serverUrl,
            tokens: {
                accessToken: tokens.access_token,
                refreshToken: tokens.refresh_token,
                expiresAt: tokens.expires_in ? Date.now() / 1000 + tokens.expires_in : undefined,
                scope: tokens.scope,
            },
        };

        await writeAuthStore(store);
    }

    async redirectToAuthorization(authorizationUrl: URL) {
        if (!this.onRedirect) {
            throw new UnauthorizedError("OAuth authentication required");
        }

        await this.onRedirect(authorizationUrl);
    }

    async saveCodeVerifier(codeVerifier: string) {
        this.verifier = codeVerifier;
    }

    async codeVerifier() {
        if (!this.verifier) {
            throw new Error(`No OAuth code verifier saved`);
        }

        return this.verifier;
    }
}

function oauthServers(servers: Record<string, ServerConfig>) {
    const out: Record<string, OAuthServerConfig> = {};

    for (const [name, config] of Object.entries(servers)) {
        if (config.url && config.oauth) {
            out[name] = { ...config, url: config.url, oauth: config.oauth };
        }
    }

    return out;
}

async function browserAuth(name: string, config: OAuthServerConfig, onRedirect: (url: URL) => void | Promise<void>) {
    const provider = new BrowserOAuthProvider(name, config, onRedirect);
    const code = await new Promise<string | undefined>((resolve, reject) => {
        const timeout = setTimeout(() => finish(new Error("OAuth callback timeout")), OAUTH_CALLBACK_TIMEOUT);
        let settled = false;

        const finish = (error?: unknown, code?: string) => {
            if (settled) return;
            settled = true;
            clearTimeout(timeout);
            try {
                http.close();
            } catch { }
            error ? reject(error) : resolve(code);
        };

        const http = createServer(async (req, res) => {
            const url = new URL(req.url ?? "/", "http://127.0.0.1");
            const code = url.searchParams.get("code");
            const state = url.searchParams.get("state");
            const error = url.searchParams.get("error");
            const errorDescription = url.searchParams.get("error_description");
            const message = errorDescription || error || "missing authorization code";

            if (url.pathname !== callbackUrl.pathname) {
                res.statusCode = 404;
                res.end("Not found");
                return;
            }

            if (error || !code) {
                res.end(`MCP auth failed: ${message}`);
                finish(new Error(message));
                return;
            }

            if (state !== (await provider.state())) {
                res.end("MCP auth failed: OAuth state mismatch");
                finish(new Error("OAuth state mismatch"));
                return;
            }

            res.end("MCP auth complete. You can close this tab.");
            finish(undefined, code);
        });

        const callbackUrl = new URL(provider.redirectUrl);
        const callbackPort = Number(callbackUrl.port || (callbackUrl.protocol === "https:" ? 443 : 80));

        http.on("error", finish);
        http.listen(callbackPort, callbackUrl.hostname, async () => {
            try {
                const result = await auth(provider, {
                    serverUrl: config.url,
                    scope: config.oauth.scope,
                });

                if (result === "AUTHORIZED") {
                    finish();
                }
            } catch (e) {
                finish(e);
            }
        });
    });

    if (code) {
        await auth(provider, {
            serverUrl: config.url,
            authorizationCode: code,
            scope: config.oauth.scope,
        });
    }
}

function expandConfig(config: ServerConfig): ServerConfig {
    const expandRecord = (record?: Record<string, string>) =>
        record ? Object.fromEntries(Object.entries(record).map(([key, value]) => [key, expandEnv(value)])) : undefined;

    return {
        ...config,
        command: config.command ? expandEnv(config.command) : undefined,
        args: config.args?.map(expandEnv),
        env: expandRecord(config.env),
        url: config.url ? expandEnv(config.url) : undefined,
        headers: expandRecord(config.headers),
        oauth: config.oauth
            ? {
                clientId: config.oauth.clientId ? expandEnv(config.oauth.clientId) : undefined,
                clientSecret: config.oauth.clientSecret ? expandEnv(config.oauth.clientSecret) : undefined,
                scope: config.oauth.scope ? expandEnv(config.oauth.scope) : undefined,
                redirectUri: config.oauth.redirectUri ? expandEnv(config.oauth.redirectUri) : undefined,
            }
            : undefined,
    };
}

async function loadConfig(cwd: string): Promise<Record<string, ServerConfig>> {
    const files = [join(getAgentDir(), "mcp.json"), join(cwd, ".pi", "mcp.json")];
    const out: Record<string, ServerConfig> = {};

    for (const file of files) {
        const config = (await readJson(file)) as McpConfig;
        if (config.mcpServers && typeof config.mcpServers === "object") {
            Object.assign(out, config.mcpServers);
        }
    }

    return Object.fromEntries(Object.entries(out).map(([name, config]) => [name, expandConfig(config)]));
}

async function listTools(client: Client, timeout = DEFAULT_CLIENT_TIMEOUT) {
    const tools: Tool[] = [];
    let cursor: string | undefined;

    do {
        const page = await client.listTools(cursor ? { cursor } : undefined, {
            timeout,
        });
        tools.push(...(page.tools ?? []));

        if (page.nextCursor && page.nextCursor === cursor) {
            throw new Error("tools/list returned duplicate cursor");
        }
        cursor = page.nextCursor;
    } while (cursor);

    return tools;
}

async function closeServer(conn: { client: Client; transport: McpTransport }) {
    if (conn.transport instanceof StreamableHTTPClientTransport && conn.transport.sessionId) {
        await conn.transport.terminateSession().catch(() => undefined);
    }

    await conn.client.close().catch(() => undefined);
    await conn.transport.close().catch(() => undefined);
}

async function closeAllServers() {
    for (const conn of connected.splice(0)) {
        await closeServer(conn);
    }
}

async function connectServer(name: string, config: ServerConfig): Promise<Connected> {
    const client = new Client({ name: "pi-mcp", version: "1.0.0" }, { capabilities: {} });
    const type = config.type ?? (config.command ? "stdio" : "http");
    let transport: McpTransport;

    if (type === "stdio") {
        if (!config.command) {
            throw new Error("stdio MCP server requires command");
        }

        transport = new StdioClientTransport({
            command: config.command,
            args: config.args ?? [],
            env: { ...process.env, ...(config.env ?? {}) } as Record<string, string>,
            stderr: "pipe",
        });
    } else {
        if (!config.url) {
            throw new Error("http MCP server requires url");
        }

        const authProvider = config.oauth
            ? new BrowserOAuthProvider(name, { ...config, url: config.url, oauth: config.oauth })
            : undefined;
        transport = new StreamableHTTPClientTransport(new URL(config.url), {
            requestInit: { headers: config.headers ?? {} },
            authProvider,
        });
    }

    try {
        const timeout = config.timeout ?? DEFAULT_CLIENT_TIMEOUT;
        await client.connect(transport, { timeout });
        const tools = await listTools(client, timeout);
        return { name, config, client, transport, tools };
    } catch (error) {
        await closeServer({ client, transport });
        throw error;
    }
}

function truncationMarker(details: McpToolDetails) {
    const { truncation, fullOutputPath } = details;
    const warnings = [`Full output: ${fullOutputPath}`];

    if (truncation.truncatedBy === "lines") {
        warnings.push(`Truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines`);
    } else {
        const limit = formatSize(truncation.maxBytes ?? DEFAULT_MAX_BYTES);
        warnings.push(`Truncated: ${truncation.outputLines} lines shown (${limit} limit)`);
    }

    return `[${warnings.join(". ")}]`;
}

async function toPiContent(items: ContentBlock[]) {
    let details: McpToolDetails | undefined;
    const content: PiToolContent = [];
    const source: ContentBlock[] = items.length ? items : [{ type: "text", text: "[Empty result]" }];
    const textBlocks: string[] = [];

    for (const item of source) {
        if (item.type === "text") {
            textBlocks.push(item.text);
            continue;
        }

        if (item.type === "image") {
            content.push({
                type: "image",
                data: item.data,
                mimeType: item.mimeType,
            });
        }
    }

    if (textBlocks.length) {
        const text = textBlocks.join("\n");
        const truncated = truncateHead(text, {
            maxBytes: DEFAULT_MAX_BYTES,
            maxLines: DEFAULT_MAX_LINES,
        });

        let output = truncated.content;
        if (truncated.truncated) {
            const fullOutputPath = join(tmpdir(), `pi-mcp-${randomBytes(8).toString("hex")}.txt`);

            await withFileMutationQueue(fullOutputPath, async () => {
                await writeFile(fullOutputPath, text, { encoding: "utf8", mode: 0o600 });
            });

            details = { truncation: truncated, fullOutputPath };
            output += `\n\n${truncationMarker(details)}`;
        }

        content.push({ type: "text", text: output });
    }

    return { content, details };
}

function registeredToolCount(conn: Connected) {
    const allow = new Set(conn.config.tools ?? []);

    if (!allow.size) {
        return conn.tools.length;
    }

    return conn.tools.filter((tool) => allow.has(tool.name)).length;
}

function registerMcpTool(pi: ExtensionAPI, conn: Connected, name: string, tool: Tool) {
    const config = conn.config;
    const existingToolNames = new Set(pi.getAllTools().map((tool) => tool.name));
    const baseToolName = sanitizeName(`${name}_${tool.name}`);
    const promptSnippet = `Tool ${tool.name} from MCP server "${name}"`;
    let toolName = baseToolName;
    let suffix = 2;

    while (existingToolNames.has(toolName)) {
        toolName = `${baseToolName}_${suffix++}`;
    }

    pi.registerTool(
        defineTool<ToolDefinition["parameters"], McpToolDetails | undefined>({
            name: toolName,
            label: toolName,
            description: tool.description || promptSnippet,
            promptSnippet: promptSnippet,
            parameters: (tool.inputSchema ?? {
                type: "object",
                properties: {},
            }) as ToolDefinition["parameters"],

            renderCall(args, theme, context) {
                const callArgs = context.args ?? args ?? {};
                const argsText = JSON.stringify(callArgs, null, 2);
                const call = argsText === "{}" ? toolName : `${toolName} ${argsText}`;
                return new Text(`${theme.fg("toolTitle", theme.bold(call))}\n`, 0, 0);
            },

            renderResult(result, options, theme) {
                const details = result.details;
                let output = result.content
                    .filter((item) => item.type === "text")
                    .map((item) => item.text)
                    .join("\n");

                if (details && output.endsWith("]")) {
                    const footerStart = output.lastIndexOf("\n\n[");
                    if (footerStart !== -1 && output.slice(footerStart).includes(details.fullOutputPath)) {
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
                            const expand = keyHint("app.tools.expand", "to expand)");
                            const hint = `${theme.fg("muted", `... (${remaining} more lines,`)} ${expand}`;
                            displayLines.push(...new Text(hint, 0, 0).render(width));
                        }

                        if (details) {
                            displayLines.push(
                                ...new Text(`\n${theme.fg("warning", truncationMarker(details))}`, 0, 0).render(width),
                            );
                        }

                        return displayLines;
                    },
                    invalidate() { },
                };
            },

            async execute(_id, params, signal) {
                const result = (await conn.client.callTool(
                    { name: tool.name, arguments: params as Record<string, unknown> },
                    CallToolResultSchema,
                    { signal, timeout: config.timeout ?? DEFAULT_CLIENT_TIMEOUT },
                )) as CallToolResult;

                const { content, details } = await toPiContent(result.content);
                if (result.isError) {
                    throw new Error(
                        content
                            .filter((item) => item.type === "text")
                            .map((item) => item.text)
                            .join("\n") || "Tool execution failed",
                    );
                }

                return { content, details };
            },
        }),
    );
}

async function connectAllServers(pi: ExtensionAPI, ctx: ExtensionContext) {
    let servers: Record<string, ServerConfig>;

    try {
        servers = await loadConfig(ctx.cwd);
    } catch (e) {
        ctx.ui.notify(`Failed to load MCP config: ${errorMessage(e)}`, "warning");
        return;
    }

    for (const [name, config] of Object.entries(servers)) {
        try {
            const allow = new Set(config.tools ?? []);
            const conn = await connectServer(name, config);
            connected.push(conn);

            for (const tool of conn.tools) {
                if (allow.size && !allow.has(tool.name)) {
                    continue;
                }
                registerMcpTool(pi, conn, name, tool);
            }
        } catch (e) {
            ctx.ui.notify(`MCP server "${name}": ${errorMessage(e)}`, "warning");
        }
    }
}

export default function mcp(pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        void connectAllServers(pi, ctx);
    });

    pi.on("session_shutdown", async () => {
        await closeAllServers();
    });

    pi.registerCommand("mcp-auth", {
        description: "Authorize an HTTP MCP server with browser OAuth",
        handler: async (_args, ctx) => {
            let servers: Record<string, ServerConfig>;

            try {
                servers = await loadConfig(ctx.cwd);
            } catch (e) {
                return ctx.ui.notify(`Failed to load MCP config: ${errorMessage(e)}`, "warning");
            }

            const oauth = oauthServers(servers);
            const names = Object.keys(oauth);
            if (!names.length) {
                return ctx.ui.notify("No OAuth MCP servers configured", "info");
            }

            const name = await ctx.ui.select("Select MCP server to authorize:", names);
            if (!name) return;
            const config = oauth[name]!;

            try {
                await browserAuth(name, config, async (url) => {
                    ctx.ui.notify(`Open this URL to authorize MCP server "${name}":\n${url}`, "info");

                    if (process.platform === "darwin") {
                        await pi.exec("open", [url.toString()]).catch(() => undefined);
                    } else if (process.platform === "win32") {
                        await pi.exec("cmd", ["/c", "start", "", url.toString()]).catch(() => undefined);
                    } else {
                        await pi.exec("xdg-open", [url.toString()]).catch(() => undefined);
                    }
                });
            } catch (e) {
                return ctx.ui.notify(`OAuth failed for MCP server "${name}": ${errorMessage(e)}`, "warning");
            }

            ctx.ui.notify(`MCP server "${name}" authenticated, run /reload`, "info");
        },
    });

    pi.registerCommand("mcp-logout", {
        description: "Remove stored MCP OAuth credentials",
        handler: async (_args, ctx) => {
            let servers: Record<string, ServerConfig>;

            try {
                servers = await loadConfig(ctx.cwd);
            } catch (e) {
                return ctx.ui.notify(`Failed to load MCP config: ${errorMessage(e)}`, "warning");
            }

            const oauth = oauthServers(servers);
            const names = Object.keys(oauth);
            if (!names.length) {
                return ctx.ui.notify("No OAuth MCP servers configured", "info");
            }

            const name = await ctx.ui.select("Select MCP server to logout:", names);
            if (!name) return;
            const config = oauth[name]!;

            try {
                const store = await readAuthStore();
                delete store[authKey(name, config.url)];
                await writeAuthStore(store);
            } catch (e) {
                return ctx.ui.notify(`Failed to update MCP auth store: ${errorMessage(e)}`, "warning");
            }

            ctx.ui.notify(`MCP server "${name}" logged out, run /reload`, "info");
        },
    });

    pi.registerCommand("mcp-status", {
        description: "Show MCP servers and tools",
        handler: async (_args, ctx) => {
            if (!connected.length) {
                return ctx.ui.notify("No connected MCP servers", "info");
            }

            const total = connected.reduce((sum, conn) => sum + registeredToolCount(conn), 0);
            const lines = connected.map((conn) => {
                const count = registeredToolCount(conn);
                return `${conn.name}: ${count}/${conn.tools.length} tool(s) registered`;
            });

            ctx.ui.notify([`${total} MCP tool(s) registered`, ...lines].join("\n"), "info");
        },
    });
}
