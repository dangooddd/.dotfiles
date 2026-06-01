import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    truncateHead,
    withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { auth, type OAuthClientProvider } from "@modelcontextprotocol/sdk/client/auth.js";
import { readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { createServer } from "node:http";
import { randomBytes } from "node:crypto";
import { tmpdir } from "node:os";
import { Text } from "@earendil-works/pi-tui";

type ServerConfig = {
    type?: "stdio" | "http";
    command?: string;
    args?: string[];
    env?: Record<string, string>;
    cwd?: string;
    url?: string;
    headers?: Record<string, string>;
    tools?: string[];
    enabled?: boolean;
    timeout?: number;
    oauth?:
        | false
        | {
              clientId?: string;
              clientSecret?: string;
              scope?: string;
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
        clientInformation?: any;
        codeVerifier?: string;
    }
>;

type McpConfig = { mcpServers?: Record<string, ServerConfig> };
type Connected = {
    name: string;
    config: ServerConfig;
    client: Client;
    transport: any;
    tools: any[];
};

const connected: Connected[] = [];
const registeredToolNames = new Set<string>();
const authPath = join(process.env.PI_CODING_AGENT_DIR || join(process.env.HOME || "", ".pi", "agent"), "mcp-auth.json");

const expandEnv = (s: string) =>
    s.replace(
        /\{env:([A-Z0-9_]+)\}|\$\{([A-Z0-9_]+)\}|\$([A-Z0-9_]+)/gi,
        (_, a, b, c) => process.env[a || b || c] ?? "",
    );

const sanitizeName = (s: string) => s.replace(/[^a-zA-Z0-9_]/g, "_").replace(/^_+|_+$/g, "") || "mcp";

async function readJson(path: string) {
    if (!existsSync(path)) {
        return {};
    }

    return JSON.parse(await readFile(path, "utf8"));
}

const readAuthStore = async () => (await readJson(authPath)) as AuthStore;

async function writeAuthStore(store: any) {
    await writeFile(authPath, JSON.stringify(store, null, 2), { mode: 0o600 });
}

function authKey(name: string, serverUrl?: string) {
    return `${name}|${serverUrl ?? ""}`;
}

class BrowserOAuthProvider implements OAuthClientProvider {
    private redirect = "";

    constructor(
        private name: string,
        private config: ServerConfig,
        private onRedirect?: (url: URL) => void | Promise<void>,
    ) {}

    setRedirectUrl(url: string) {
        this.redirect = url;
    }

    get redirectUrl() {
        return this.redirect;
    }

    get clientMetadata() {
        return {
            redirect_uris: [this.redirect],
            token_endpoint_auth_method:
                this.config.oauth && this.config.oauth.clientSecret ? "client_secret_basic" : "none",
            grant_types: ["authorization_code", "refresh_token"],
            response_types: ["code"],
            client_name: "Pi MCP",
            scope: this.config.oauth && this.config.oauth.scope ? expandEnv(this.config.oauth.scope) : undefined,
        };
    }

    async clientInformation() {
        const store = await readAuthStore();
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
        const saved = store[authKey(this.name, serverUrl)]?.clientInformation;

        if (saved) {
            return saved;
        }

        if (this.config.oauth && this.config.oauth.clientId) {
            return {
                client_id: expandEnv(this.config.oauth.clientId),
                client_secret: this.config.oauth.clientSecret ? expandEnv(this.config.oauth.clientSecret) : undefined,
            };
        }
    }

    async saveClientInformation(clientInformation: any) {
        const store = await readAuthStore();
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
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
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
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

    async saveTokens(tokens: any) {
        const store = await readAuthStore();
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
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
            throw new Error(`OAuth required for MCP server: ${this.name}`);
        }

        await this.onRedirect(authorizationUrl);
    }

    async saveCodeVerifier(codeVerifier: string) {
        const store = await readAuthStore();
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
        const key = authKey(this.name, serverUrl);
        store[key] = {
            ...(store[key] ?? {}),
            serverName: this.name,
            serverUrl,
            codeVerifier,
        };
        await writeAuthStore(store);
    }

    async codeVerifier() {
        const store = await readAuthStore();
        const serverUrl = this.config.url ? expandEnv(this.config.url) : undefined;
        const codeVerifier = store[authKey(this.name, serverUrl)]?.codeVerifier;

        if (!codeVerifier) {
            throw new Error(`No OAuth code verifier saved for MCP server: ${this.name}`);
        }

        return codeVerifier;
    }
}

async function browserAuth(name: string, config: ServerConfig, onRedirect: (url: URL) => void | Promise<void>) {
    if (!config.url) {
        throw new Error("browser OAuth requires http MCP server url");
    }

    const provider = new BrowserOAuthProvider(name, config, onRedirect);
    const code = await new Promise<string>((resolve, reject) => {
        const http = createServer((req, res) => {
            const url = new URL(req.url ?? "/", "http://127.0.0.1");
            const code = url.searchParams.get("code");
            const error = url.searchParams.get("error");

            res.end(
                code ? "MCP auth complete. You can close this tab." : `MCP auth failed: ${error ?? "missing code"}`,
            );
            http.close();

            if (code) {
                resolve(code);
            } else {
                reject(new Error(error ?? "missing authorization code"));
            }
        });

        http.listen(0, "127.0.0.1", async () => {
            const addr = http.address();
            const port = typeof addr === "object" && addr ? addr.port : 0;
            provider.setRedirectUrl(`http://127.0.0.1:${port}/callback`);

            try {
                await auth(provider, {
                    serverUrl: expandEnv(config.url!),
                    scope: config.oauth && config.oauth.scope ? expandEnv(config.oauth.scope) : undefined,
                });
            } catch (e) {
                http.close();
                reject(e);
            }
        });
    });

    await auth(provider, {
        serverUrl: expandEnv(config.url),
        authorizationCode: code,
        scope: config.oauth && config.oauth.scope ? expandEnv(config.oauth.scope) : undefined,
    });
}

function expandRecord(record?: Record<string, string>) {
    return Object.fromEntries(Object.entries(record ?? {}).map(([key, value]) => [key, expandEnv(value)]));
}

async function loadConfig(cwd: string): Promise<Record<string, ServerConfig>> {
    const home = process.env.PI_CODING_AGENT_DIR || join(process.env.HOME || "", ".pi", "agent");
    const files = [join(home, "mcp.json"), join(cwd, ".pi", "mcp.json")];
    const out: Record<string, ServerConfig> = {};

    for (const file of files) {
        const config = (await readJson(file)) as McpConfig;

        if (config.mcpServers && typeof config.mcpServers === "object") {
            Object.assign(out, config.mcpServers);
        }
    }

    return out;
}

async function listTools(client: Client, timeout = 10_000) {
    const tools: any[] = [];

    for (let cursor: string | undefined = undefined; ; ) {
        const page = await client.listTools(cursor ? { cursor } : undefined, {
            timeout,
        });

        tools.push(...(page.tools ?? []));
        cursor = page.nextCursor;

        if (!cursor) {
            break;
        }
    }

    return tools;
}

async function connectServer(name: string, config: ServerConfig): Promise<Connected> {
    const client = new Client({ name: "pi-mcp", version: "0.1.0" }, { capabilities: {} });
    const type = config.type ?? (config.command ? "stdio" : "http");
    let transport: any;

    if (type === "stdio") {
        if (!config.command) {
            throw new Error("stdio MCP server requires command");
        }

        transport = new StdioClientTransport({
            command: expandEnv(config.command),
            args: (config.args ?? []).map(expandEnv),
            env: { ...process.env, ...expandRecord(config.env) } as Record<string, string>,
            cwd: config.cwd ? expandEnv(config.cwd) : undefined,
            stderr: "pipe",
        });
    } else {
        if (!config.url) {
            throw new Error("http MCP server requires url");
        }

        const headers = expandRecord(config.headers);

        const authProvider = config.oauth ? new BrowserOAuthProvider(name, config) : undefined;

        transport = new StreamableHTTPClientTransport(new URL(expandEnv(config.url)), {
            requestInit: { headers },
            authProvider,
        });
    }

    await client.connect(transport, { timeout: config.timeout ?? 10_000 });
    const tools = await listTools(client, config.timeout ?? 10_000);
    return { name, config, client, transport, tools };
}

async function toPiContent(items: any[]) {
    const content = [];

    for (const item of items?.length ? items : [{ type: "text", text: "" }]) {
        if (item.type === "text") {
            const original = String(item.text ?? "");
            const truncated = truncateHead(original, {
                maxBytes: DEFAULT_MAX_BYTES,
                maxLines: DEFAULT_MAX_LINES,
            });

            let text = truncated.content;
            if (truncated.truncated) {
                const fullOutputPath = join(tmpdir(), `pi-mcp-${randomBytes(8).toString("hex")}.txt`);

                await withFileMutationQueue(fullOutputPath, async () => {
                    await writeFile(fullOutputPath, original, "utf8");
                });

                text += `\n\n[Full output: ${fullOutputPath}. Truncated: ${truncated.outputLines} lines shown]`;
            }

            content.push({ type: "text" as const, text });
            continue;
        }

        if (item.type === "image") {
            content.push({
                type: "image" as const,
                data: item.data,
                mimeType: item.mimeType,
            });
            continue;
        }

        content.push({ type: "text" as const, text: JSON.stringify(item) });
    }

    return content;
}

function uniqueToolName(name: string, toolName: string) {
    const base = sanitizeName(`${name}_${toolName}`);
    let candidate = base;
    let suffix = 2;

    while (registeredToolNames.has(candidate)) {
        candidate = `${base}_${suffix++}`;
    }

    registeredToolNames.add(candidate);
    return candidate;
}

function registeredToolCount(conn: Connected) {
    const allow = new Set(conn.config.tools ?? []);

    if (!allow.size) {
        return conn.tools.length;
    }

    return conn.tools.filter((tool) => allow.has(tool.name)).length;
}

function registerMcpTool(pi: ExtensionAPI, conn: Connected, name: string, tool: any) {
    const toolName = uniqueToolName(name, tool.name);
    const config = conn.config;

    pi.registerTool(
        defineTool({
            name: toolName,
            label: `MCP ${name}/${tool.name}`,
            description: tool.description || `MCP tool ${tool.name} from ${name}`,
            promptSnippet: `Call MCP ${name}/${tool.name}`,
            parameters: (tool.inputSchema ?? {
                type: "object",
                properties: {},
            }) as any,

            renderCall(args, theme, context) {
                const callArgs = context.args ?? args ?? {};
                const argsText = JSON.stringify(callArgs, null, 2);

                return new Text(
                    `${theme.fg("toolTitle", theme.bold(toolName))} ${theme.fg("muted", theme.bold(argsText))}\n`,
                    0,
                    0,
                );
            },

            renderResult(result, _options, theme) {
                const text = ((result as any).content ?? [])
                    .map((item: any) => (item.type === "text" ? String(item.text ?? "") : "[image]"))
                    .join("\n");

                const marker = text.match(/\n\n(\[Full output: [^\]]+\. Truncated: \d+ lines shown\])$/);
                const output = marker ? text.slice(0, marker.index).trimEnd() : text;

                let rendered = output ? theme.fg("toolOutput", output) : "";
                if (marker) {
                    rendered += `${rendered ? "\n\n" : ""}${theme.fg("warning", marker[1])}`;
                }

                return new Text(rendered, 0, 0);
            },

            async execute(_id, params, signal) {
                const result: any = await conn.client.callTool(
                    { name: tool.name, arguments: params as any },
                    undefined,
                    {
                        signal,
                        timeout: config.timeout ?? 60_000,
                    },
                );

                const content = await toPiContent(result.content);
                if (result.isError) {
                    throw new Error(content.map((item: any) => item.text ?? "[image]").join("\n"));
                }

                return { content, details: undefined };
            },
        }),
    );
}

export default function mcp(pi: ExtensionAPI) {
    async function closeAll() {
        for (const conn of connected.splice(0)) {
            try {
                await conn.transport.terminateSession?.();
            } catch {}

            try {
                await conn.client.close();
            } catch {}
        }
    }

    pi.on("session_start", async (_event, ctx) => {
        const servers = await loadConfig(ctx.cwd);

        for (const [name, config] of Object.entries(servers)) {
            if (config.enabled === false) {
                continue;
            }

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
            } catch (e: any) {
                ctx.ui.notify(`MCP ${name}: ${e?.message ?? e}`, "warning");
            }
        }
    });

    pi.on("session_shutdown", async () => {
        await closeAll();
    });

    pi.registerCommand("mcp-auth", {
        description: "Authorize an HTTP MCP server with browser OAuth",
        handler: async (args, ctx) => {
            const name = String(args ?? "").trim();

            if (!name) {
                return ctx.ui.notify("Usage: /mcp-auth <server>", "warning");
            }

            const servers = await loadConfig(ctx.cwd);
            const config = servers[name];

            if (!config) {
                return ctx.ui.notify(`MCP ${name}: not found`, "warning");
            }

            await browserAuth(name, config, async (url) => {
                ctx.ui.notify(`MCP ${name}: open this URL to authorize\n${url}`, "info");
            });
            ctx.ui.notify(`MCP ${name}: auth complete, run /mcp-reload`, "info");
        },
    });

    pi.registerCommand("mcp-logout", {
        description: "Remove stored MCP OAuth credentials",
        handler: async (args, ctx) => {
            const name = String(args ?? "").trim();

            if (!name) {
                return ctx.ui.notify("Usage: /mcp-logout <server>", "warning");
            }

            const servers = await loadConfig(ctx.cwd);
            const config = servers[name];

            if (!config?.url) {
                return ctx.ui.notify(`MCP ${name}: HTTP server with url not found`, "warning");
            }

            const store = await readAuthStore();
            delete store[authKey(name, expandEnv(config.url))];
            await writeAuthStore(store);

            ctx.ui.notify(`MCP ${name}: logged out, run /mcp-reload`, "info");
        },
    });

    pi.registerCommand("mcp-reload", {
        description: "Reload Pi runtime after MCP config/auth changes",
        handler: async (_args, ctx) => {
            await closeAll();
            await ctx.reload();
        },
    });

    pi.registerCommand("mcp-status", {
        description: "Show MCP servers and tools",
        handler: async (_args, ctx) => {
            if (!connected.length) {
                return ctx.ui.notify("MCP: no connected servers", "info");
            }

            const total = connected.reduce((sum, conn) => sum + registeredToolCount(conn), 0);
            const lines = connected.map((conn) => {
                const count = registeredToolCount(conn);
                return `${conn.name}: ${count}/${conn.tools.length} tool(s) registered`;
            });

            ctx.ui.notify([`MCP: ${total} registered tool(s)`, ...lines].join("\n"), "info");
        },
    });
}
