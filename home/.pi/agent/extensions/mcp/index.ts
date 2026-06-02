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
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
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

const MAX_RENDERED_ARGS_CHARS = 1000;
const MAX_TOOLS_PAGES = 100;
const OAUTH_CALLBACK_TIMEOUT = 300000;
const connected: Connected[] = [];
const authPath = join(process.env.PI_CODING_AGENT_DIR || join(process.env.HOME || "", ".pi", "agent"), "mcp-auth.json");

const expandEnv = (s: string) =>
    s.replace(
        /\{env:([A-Z0-9_]+)\}|\$\{([A-Z0-9_]+)\}|\$([A-Z0-9_]+)/gi,
        (_, a, b, c) => process.env[a || b || c] ?? "",
    );

const sanitizeName = (s: string) => s.replace(/[^a-zA-Z0-9_]/g, "_").replace(/^_+|_+$/g, "") || "mcp";

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
    private redirect = "";
    private verifier?: string;
    private oauthState = randomBytes(32).toString("hex");

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

    get expectedState() {
        return this.oauthState;
    }

    async state() {
        return this.oauthState;
    }

    get clientMetadata() {
        return {
            redirect_uris: [this.redirect],
            token_endpoint_auth_method:
                this.config.oauth && this.config.oauth.clientSecret ? "client_secret_basic" : "none",
            grant_types: ["authorization_code", "refresh_token"],
            response_types: ["code"],
            client_name: "Pi MCP",
            scope: this.config.oauth && this.config.oauth.scope ? this.config.oauth.scope : undefined,
        };
    }

    async clientInformation() {
        const store = await readAuthStore();
        const serverUrl = this.config.url!;
        const saved = store[authKey(this.name, serverUrl)]?.clientInformation;

        if (saved) {
            return saved;
        }

        if (this.config.oauth && this.config.oauth.clientId) {
            return {
                client_id: this.config.oauth.clientId,
                client_secret: this.config.oauth.clientSecret,
            };
        }
    }

    async saveClientInformation(clientInformation: any) {
        const store = await readAuthStore();
        const serverUrl = this.config.url!;
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
        const serverUrl = this.config.url!;
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
        const serverUrl = this.config.url!;
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
        this.verifier = codeVerifier;
    }

    async codeVerifier() {
        if (!this.verifier) {
            throw new Error(`No OAuth code verifier saved for MCP server: ${this.name}`);
        }

        return this.verifier;
    }
}

async function browserAuth(name: string, config: ServerConfig, onRedirect: (url: URL) => void | Promise<void>) {
    if (!config.url) {
        throw new Error("browser OAuth requires http MCP server url");
    }

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
            } catch {}
            error ? reject(error) : resolve(code);
        };

        const http = createServer((req, res) => {
            const url = new URL(req.url ?? "/", "http://127.0.0.1");
            const code = url.searchParams.get("code");
            const state = url.searchParams.get("state");
            const error = url.searchParams.get("error");
            const errorDescription = url.searchParams.get("error_description");
            const message = errorDescription || error || "missing authorization code";

            if (url.pathname !== "/callback") {
                res.statusCode = 404;
                res.end("Not found");
                return;
            }

            if (error || !code) {
                res.end(`MCP auth failed: ${message}`);
                finish(new Error(message));
                return;
            }

            if (state !== provider.expectedState) {
                res.end("MCP auth failed: invalid OAuth state");
                finish(new Error("invalid OAuth state"));
                return;
            }

            res.end("MCP auth complete. You can close this tab.");
            finish(undefined, code);
        });

        http.on("error", finish);
        http.listen(0, "127.0.0.1", async () => {
            const addr = http.address();
            const port = typeof addr === "object" && addr ? addr.port : 0;
            provider.setRedirectUrl(`http://127.0.0.1:${port}/callback`);

            try {
                const result = await auth(provider, {
                    serverUrl: config.url!,
                    scope: config.oauth && config.oauth.scope ? config.oauth.scope : undefined,
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
            scope: config.oauth && config.oauth.scope ? config.oauth.scope : undefined,
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
        cwd: config.cwd ? expandEnv(config.cwd) : undefined,
        url: config.url ? expandEnv(config.url) : undefined,
        headers: expandRecord(config.headers),
        oauth: config.oauth
            ? {
                  clientId: config.oauth.clientId ? expandEnv(config.oauth.clientId) : undefined,
                  clientSecret: config.oauth.clientSecret ? expandEnv(config.oauth.clientSecret) : undefined,
                  scope: config.oauth.scope ? expandEnv(config.oauth.scope) : undefined,
              }
            : config.oauth,
    };
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

    return Object.fromEntries(Object.entries(out).map(([name, config]) => [name, expandConfig(config)]));
}

async function listTools(client: Client, timeout = 10000) {
    const tools: any[] = [];

    for (let cursor: string | undefined = undefined, pageCount = 0; pageCount < MAX_TOOLS_PAGES; pageCount++) {
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
            command: config.command,
            args: config.args ?? [],
            env: { ...process.env, ...(config.env ?? {}) } as Record<string, string>,
            cwd: config.cwd,
            stderr: "pipe",
        });
    } else {
        if (!config.url) {
            throw new Error("http MCP server requires url");
        }

        const authProvider = config.oauth ? new BrowserOAuthProvider(name, config) : undefined;
        transport = new StreamableHTTPClientTransport(new URL(config.url), {
            requestInit: { headers: config.headers ?? {} },
            authProvider,
        });
    }

    try {
        await client.connect(transport, { timeout: config.timeout ?? 10000 });
        const tools = await listTools(client, config.timeout ?? 10000);
        return { name, config, client, transport, tools };
    } catch (error) {
        await client.close().catch(() => undefined);
        await transport.close?.().catch(() => undefined);
        throw error;
    }
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
                    await writeFile(fullOutputPath, original, { encoding: "utf8", mode: 0o600 });
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

function registeredToolCount(conn: Connected) {
    const allow = new Set(conn.config.tools ?? []);

    if (!allow.size) {
        return conn.tools.length;
    }

    return conn.tools.filter((tool) => allow.has(tool.name)).length;
}

function registerMcpTool(pi: ExtensionAPI, conn: Connected, name: string, tool: any) {
    const config = conn.config;
    const existingToolNames = new Set(pi.getAllTools().map((tool) => tool.name));
    const baseToolName = sanitizeName(`${name}_${tool.name}`);
    let toolName = baseToolName;
    let suffix = 2;

    while (existingToolNames.has(toolName)) {
        toolName = `${baseToolName}_${suffix++}`;
    }

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
                const renderedArgs =
                    argsText.length <= MAX_RENDERED_ARGS_CHARS ? ` ${theme.fg("muted", theme.bold(argsText))}` : "";

                return new Text(`${theme.fg("toolTitle", theme.bold(toolName))}${renderedArgs}\n`, 0, 0);
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
                        timeout: config.timeout ?? 60000,
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
        let servers: Record<string, ServerConfig>;

        try {
            servers = await loadConfig(ctx.cwd);
        } catch (e: any) {
            ctx.ui.notify(`Failed to load MCP config: ${e?.message ?? e}`, "warning");
            return;
        }

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
                ctx.ui.notify(`MCP server "${name}": ${e?.message ?? e}`, "warning");
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
                return ctx.ui.notify("Server name is required: /mcp-auth <server>", "warning");
            }

            let servers: Record<string, ServerConfig>;

            try {
                servers = await loadConfig(ctx.cwd);
            } catch (e: any) {
                return ctx.ui.notify(`Failed to load MCP config: ${e?.message ?? e}`, "warning");
            }

            const config = servers[name];

            if (!config) {
                return ctx.ui.notify(`MCP server "${name}" not found`, "warning");
            }

            if (!config.url) {
                return ctx.ui.notify(`MCP server "${name}" is not an HTTP server`, "warning");
            }

            if (!config.oauth) {
                return ctx.ui.notify(`OAuth is not enabled for MCP server "${name}"`, "warning");
            }

            try {
                await browserAuth(name, config, async (url) => {
                    ctx.ui.notify(`Open this URL to authorize MCP server "${name}"\n${url}`, "info");
                });
            } catch (e: any) {
                return ctx.ui.notify(`OAuth failed for MCP server "${name}": ${e?.message ?? e}`, "warning");
            }

            ctx.ui.notify(`MCP server "${name}" authenticated, run /mcp-reload`, "info");
        },
    });

    pi.registerCommand("mcp-logout", {
        description: "Remove stored MCP OAuth credentials",
        handler: async (args, ctx) => {
            const name = String(args ?? "").trim();

            if (!name) {
                return ctx.ui.notify("Server name is required: /mcp-logout <server>", "warning");
            }

            let servers: Record<string, ServerConfig>;

            try {
                servers = await loadConfig(ctx.cwd);
            } catch (e: any) {
                return ctx.ui.notify(`Failed to load MCP config: ${e?.message ?? e}`, "warning");
            }

            const config = servers[name];

            if (!config?.url) {
                return ctx.ui.notify(`HTTP MCP server "${name}" not found`, "warning");
            }

            try {
                const store = await readAuthStore();
                delete store[authKey(name, config.url)];
                await writeAuthStore(store);
            } catch (e: any) {
                return ctx.ui.notify(`Failed to update MCP auth store: ${e?.message ?? e}`, "warning");
            }

            ctx.ui.notify(`MCP server "${name}" logged out, run /mcp-reload`, "info");
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
