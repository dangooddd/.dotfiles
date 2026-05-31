import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { UnauthorizedError } from "@modelcontextprotocol/sdk/client/auth.js";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";
import type { AdapterConfig, McpTool, ServerConnection, ServerDefinition, ServerStatus, TransportLike } from "./types.js";
import { buildProcessEnv } from "./config.js";
import { BrowserOAuthProvider, OAuthCallbackServer, callbackOptionsFromRedirectUri, clearAllCredentials, openUrl } from "./oauth.js";

export class AuthRequiredError extends Error {
  constructor(public readonly serverName: string) {
    super(`OAuth is required for MCP server "${serverName}". Run /mcp auth ${serverName}.`);
    this.name = "AuthRequiredError";
  }
}

interface CreateTransportOptions {
  interactiveOAuth?: boolean;
  redirectUrl?: string;
  onAuthUrl?: (url: URL) => Promise<void> | void;
}

export class McpManager {
  private readonly connections = new Map<string, ServerConnection>();
  private readonly connectPromises = new Map<string, Promise<ServerConnection>>();
  private readonly statuses = new Map<string, ServerStatus>();

  constructor(private readonly config: AdapterConfig) {
    for (const [name, definition] of Object.entries(config.servers)) {
      const enabledTools = enabledToolsSummary(definition);
      this.statuses.set(name, {
        state: isServerEnabled(definition) ? "configured" : "disabled",
        tools: 0,
        registeredTools: 0,
        enabledTools,
      });
    }
  }

  listServerNames(): string[] {
    return Object.keys(this.config.servers).sort();
  }

  listEnabledServerNames(): string[] {
    return this.listServerNames().filter((name) => isServerEnabled(this.requireDefinition(name)));
  }

  getDefinition(serverName: string): ServerDefinition | undefined {
    return this.config.servers[serverName];
  }

  getConnection(serverName: string): ServerConnection | undefined {
    return this.connections.get(serverName);
  }

  getStatus(serverName: string): ServerStatus | undefined {
    return this.statuses.get(serverName);
  }

  filterEnabledTools(serverName: string, tools: McpTool[]): { tools: McpTool[]; missingTools: string[] } {
    const definition = this.requireDefinition(serverName);
    const enable = definition.enable;

    if (enable === true) return { tools, missingTools: [] };
    if (!Array.isArray(enable) || enable.length === 0) return { tools: [], missingTools: [] };

    const selected = tools.filter((tool) =>
      enable.some((requested) =>
        sameToolName(requested, tool.name) || sameToolName(requested, publicToolName(serverName, tool.name)),
      ),
    );

    const missingTools = enable.filter((requested) =>
      !tools.some((tool) =>
        sameToolName(requested, tool.name) || sameToolName(requested, publicToolName(serverName, tool.name)),
      ),
    );

    return { tools: selected, missingTools };
  }

  recordRegisteredTools(serverName: string, registeredTools: number, missingTools: string[] = []): void {
    const previous = this.statuses.get(serverName);
    if (!previous) return;
    this.statuses.set(serverName, {
      ...previous,
      registeredTools,
      missingTools: missingTools.length ? missingTools : undefined,
    });
  }

  async connect(serverName: string): Promise<ServerConnection> {
    const definition = this.requireDefinition(serverName);

    const existing = this.connections.get(serverName);
    if (existing) {
      existing.lastUsedAt = Date.now();
      return existing;
    }

    const inFlight = this.connectPromises.get(serverName);
    if (inFlight) return inFlight;

    const promise = this.createConnection(serverName, definition);
    this.connectPromises.set(serverName, promise);
    try {
      const connection = await promise;
      this.connections.set(serverName, connection);
      this.statuses.set(serverName, {
        state: "connected",
        tools: connection.tools.length,
        registeredTools: this.statuses.get(serverName)?.registeredTools ?? 0,
        enabledTools: enabledToolsSummary(definition),
      });
      return connection;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.statuses.set(serverName, {
        state: error instanceof AuthRequiredError ? "needs-auth" : "failed",
        tools: 0,
        registeredTools: this.statuses.get(serverName)?.registeredTools ?? 0,
        enabledTools: enabledToolsSummary(definition),
        error: message,
      });
      throw error;
    } finally {
      this.connectPromises.delete(serverName);
    }
  }

  async callTool(serverName: string, toolName: string, args: Record<string, unknown>): Promise<CallToolResult> {
    try {
      const connection = await this.connect(serverName);
      connection.inFlight++;
      connection.lastUsedAt = Date.now();
      try {
        return await connection.client.callTool({ name: toolName, arguments: args }) as CallToolResult;
      } finally {
        connection.inFlight--;
        connection.lastUsedAt = Date.now();
      }
    } catch (error) {
      const definition = this.getDefinition(serverName);
      if ((error instanceof UnauthorizedError && definition && supportsOAuth(definition)) || error instanceof AuthRequiredError) {
        await this.close(serverName, "needs-auth");
        this.statuses.set(serverName, {
          state: "needs-auth",
          tools: 0,
          registeredTools: this.statuses.get(serverName)?.registeredTools ?? 0,
          enabledTools: definition ? enabledToolsSummary(definition) : 0,
          error: `Run /mcp auth ${serverName}.`,
        });
        throw new AuthRequiredError(serverName);
      }
      throw error;
    }
  }

  async authorize(serverName: string): Promise<string> {
    const definition = this.requireDefinition(serverName);
    if (!definition.url) throw new Error(`Server "${serverName}" is not an HTTP MCP server`);
    if (!supportsOAuth(definition)) throw new Error(`Server "${serverName}" is not configured with OAuth`);

    await this.close(serverName);

    const oauthConfig = definition.oauth === false ? undefined : definition.oauth;
    const callbackServer = await OAuthCallbackServer.start(callbackOptionsFromRedirectUri(oauthConfig?.redirectUri));
    const provider = new BrowserOAuthProvider({
      serverName,
      serverUrl: definition.url,
      redirectUrl: callbackServer.redirectUrl,
      config: oauthConfig,
      onRedirect: async (url) => {
        const opened = await openUrl(url.toString());
        if (!opened) {
          console.warn(`MCP OAuth: open this URL manually: ${url.toString()}`);
        }
      },
    });

    const url = new URL(definition.url);
    const requestInit = this.buildRequestInit(definition);
    const transport = new StreamableHTTPClientTransport(url, { requestInit, authProvider: provider }) as unknown as TransportLike;
    const client = new Client({ name: `pi-mcp-auth-${serverName}`, version: "0.1.0" });

    try {
      try {
        await client.connect(transport as never);
        await client.close().catch(() => undefined);
        await transport.close?.().catch(() => undefined);
        await callbackServer.close();
        const connection = await this.connect(serverName);
        return `Already authorized for ${serverName}. ${connection.tools.length} tool(s) discovered.`;
      } catch (error) {
        if (!(error instanceof UnauthorizedError)) throw error;
      }

      const callback = await callbackServer.waitForCallback();
      const expectedState = await provider.state().catch(() => undefined);
      if (callback.state && expectedState && callback.state !== expectedState) {
        throw new Error("OAuth state mismatch");
      }

      if (!transport.finishAuth) throw new Error("Current MCP SDK transport does not expose finishAuth()");
      await transport.finishAuth(callback.code);
      await client.close().catch(() => undefined);
      await transport.close?.().catch(() => undefined);

      const connection = await this.connect(serverName);
      return `OAuth complete for ${serverName}. ${connection.tools.length} tool(s) discovered.`;
    } finally {
      await callbackServer.close().catch(() => undefined);
      await client.close().catch(() => undefined);
      await transport.close?.().catch(() => undefined);
    }
  }

  logout(serverName: string): void {
    clearAllCredentials(serverName);
    const definition = this.getDefinition(serverName);
    this.statuses.set(serverName, {
      state: definition && isServerEnabled(definition) ? "configured" : "disabled",
      tools: 0,
      registeredTools: this.statuses.get(serverName)?.registeredTools ?? 0,
      enabledTools: definition ? enabledToolsSummary(definition) : 0,
    });
  }

  async close(serverName: string, nextState: "closed" | "needs-auth" = "closed"): Promise<void> {
    const connection = this.connections.get(serverName);
    this.connections.delete(serverName);
    if (connection) {
      await connection.transport.terminateSession?.().catch(() => undefined);
      await connection.client.close().catch(() => undefined);
      await connection.transport.close?.().catch(() => undefined);
    }

    const previous = this.statuses.get(serverName);
    if (previous && previous.state !== "disabled") {
      this.statuses.set(serverName, { ...previous, state: nextState });
    }
  }

  async closeAll(): Promise<void> {
    await Promise.all([...this.connections.keys()].map((name) => this.close(name)));
  }

  statusText(): string {
    const lines = [
      `MCP minimal adapter`,
      `Config files: ${this.config.loadedFiles.length ? this.config.loadedFiles.join(", ") : "none"}`,
      `Servers: ${this.listServerNames().length}`,
    ];

    for (const name of this.listServerNames()) {
      const status = this.statuses.get(name);
      if (!status) continue;
      const parts = [`- ${name}: ${status.state}`];
      if (status.enabledTools === "all") parts.push("enable: all");
      else parts.push(`enable: ${status.enabledTools}`);
      if (status.tools) parts.push(`${status.tools} discovered`);
      if (status.registeredTools) parts.push(`${status.registeredTools} registered`);
      if (status.missingTools?.length) parts.push(`missing: ${status.missingTools.join(", ")}`);
      if (status.error) parts.push(status.error);
      lines.push(parts.join(", "));
    }

    return lines.join("\n");
  }

  private async createConnection(serverName: string, definition: ServerDefinition): Promise<ServerConnection> {
    const client = new Client({ name: `pi-mcp-${serverName}`, version: "0.1.0" });
    const transport = await this.createTransport(serverName, definition);

    try {
      await client.connect(transport as never);
      const tools = await this.fetchAllTools(client);

      return {
        client,
        transport,
        definition,
        tools,
        lastUsedAt: Date.now(),
        inFlight: 0,
      };
    } catch (error) {
      await client.close().catch(() => undefined);
      await transport.close?.().catch(() => undefined);
      if (error instanceof UnauthorizedError && supportsOAuth(definition)) {
        throw new AuthRequiredError(serverName);
      }
      throw error;
    }
  }

  private async createTransport(serverName: string, definition: ServerDefinition, options: CreateTransportOptions = {}): Promise<TransportLike> {
    if (definition.command) {
      return new StdioClientTransport({
        command: definition.command,
        args: definition.args ?? [],
        env: buildProcessEnv(definition.env),
        cwd: definition.cwd,
        stderr: definition.debug ? "inherit" : "ignore",
      }) as unknown as TransportLike;
    }

    if (!definition.url) throw new Error(`Server "${serverName}" has neither command nor url`);

    const authProvider = supportsOAuth(definition)
      ? new BrowserOAuthProvider({
          serverName,
          serverUrl: definition.url,
          redirectUrl: definition.oauth && typeof definition.oauth === "object" && definition.oauth.redirectUri
            ? definition.oauth.redirectUri
            : options.redirectUrl ?? `http://127.0.0.1:${Number(process.env.MCP_OAUTH_CALLBACK_PORT ?? 19876)}/mcp/oauth/callback`,
          config: definition.oauth === false ? undefined : definition.oauth,
          onRedirect: options.interactiveOAuth ? options.onAuthUrl : undefined,
        })
      : undefined;

    return new StreamableHTTPClientTransport(new URL(definition.url), {
      requestInit: this.buildRequestInit(definition),
      authProvider,
    }) as unknown as TransportLike;
  }

  private buildRequestInit(definition: ServerDefinition): { headers: Record<string, string> } | undefined {
    const headers = { ...(definition.headers ?? {}) };
    return Object.keys(headers).length ? { headers } : undefined;
  }

  private async fetchAllTools(client: Client): Promise<McpTool[]> {
    const tools: McpTool[] = [];
    let cursor: string | undefined;
    do {
      const result = await client.listTools(cursor ? { cursor } : undefined);
      tools.push(...((result.tools ?? []) as McpTool[]));
      cursor = result.nextCursor;
    } while (cursor);
    return tools;
  }

  private requireDefinition(serverName: string): ServerDefinition {
    const definition = this.config.servers[serverName];
    if (!definition) throw new Error(`Unknown MCP server "${serverName}"`);
    return definition;
  }
}

export function publicToolName(serverName: string, toolName: string): string {
  return sanitizeToolName(`${serverName}_${toolName}`);
}

function sanitizeToolName(name: string): string {
  const normalized = name
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_+/g, "_");
  return normalized || "mcp_tool";
}

function sameToolName(left: string, right: string): boolean {
  return sanitizeToolName(left) === sanitizeToolName(right);
}

export function isServerEnabled(definition: ServerDefinition): boolean {
  return definition.enable === true || (Array.isArray(definition.enable) && definition.enable.length > 0);
}

export function supportsOAuth(definition: ServerDefinition): boolean {
  return !!definition.url && definition.oauth !== false;
}

function enabledToolsSummary(definition: ServerDefinition): ServerStatus["enabledTools"] {
  if (definition.enable === true) return "all";
  if (Array.isArray(definition.enable)) return definition.enable.length;
  return 0;
}
