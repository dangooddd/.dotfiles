import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { AuthRequiredError, isServerEnabled, McpManager } from "./manager.js";

type RegisterToolsForServer = (serverName: string) => Promise<number>;
type EagerLoad = (serverName?: string) => Promise<number>;

export function registerCommands(
  pi: ExtensionAPI,
  manager: McpManager,
  registerToolsForServer: RegisterToolsForServer,
  eagerLoad: EagerLoad,
): void {
  pi.registerCommand("mcp", {
    description: "Manage minimal MCP adapter: /mcp status|auth|logout|reconnect|reload",
    handler: async (args, ctx) => {
      const message = await handleMcpCommand(args ?? "", manager, registerToolsForServer, eagerLoad, ctx);
      if (message) show(ctx, message);
    },
  });
}

async function handleMcpCommand(
  args: string,
  manager: McpManager,
  registerToolsForServer: RegisterToolsForServer,
  eagerLoad: EagerLoad,
  ctx: ExtensionCommandContext,
): Promise<string | undefined> {
  const [cmdRaw, ...rest] = args.trim().split(/\s+/).filter(Boolean);
  const cmd = (cmdRaw ?? "status").toLowerCase();

  if (cmd === "status" || cmd === "servers") return manager.statusText();

  if (cmd === "auth" || cmd === "login") {
    const server = rest[0];
    if (!server) return "Usage: /mcp auth <server>";
    return authenticate(server, manager, registerToolsForServer);
  }

  if (cmd === "logout") {
    const server = rest[0];
    if (!server) return "Usage: /mcp logout <server>";
    await manager.close(server);
    manager.logout(server);
    return `Removed OAuth credentials for ${server}. Already registered Pi tools stay until /mcp reload.`;
  }

  if (cmd === "reconnect") {
    const server = rest[0];
    if (server) {
      await manager.close(server);
      const count = await eagerLoad(server);
      return `Reconnected ${server}. Registered ${count} new tool(s).`;
    }

    await manager.closeAll();
    const count = await eagerLoad();
    return `Reconnected enabled MCP servers. Registered ${count} new tool(s).`;
  }

  if (cmd === "reload") {
    await ctx.reload();
    return undefined;
  }

  return [
    "Usage:",
    "/mcp status",
    "/mcp auth <server>",
    "/mcp logout <server>",
    "/mcp reconnect [server]",
    "/mcp reload",
  ].join("\n");
}

async function authenticate(
  serverName: string,
  manager: McpManager,
  registerToolsForServer: RegisterToolsForServer,
): Promise<string> {
  const definition = manager.getDefinition(serverName);
  if (!definition) return `Unknown MCP server: ${serverName}`;

  const authMessage = await manager.authorize(serverName);
  const registered = isServerEnabled(definition) ? await registerToolsForServer(serverName) : 0;
  return `${authMessage}\nRegistered ${registered} new Pi tool(s).`;
}

function show(ctx: ExtensionCommandContext, message: string, type: "info" | "warning" | "error" = "info"): void {
  if (ctx.hasUI) ctx.ui.notify(message, type);
  else console.log(message);
}

export function formatStartupError(serverName: string, error: unknown): string {
  if (error instanceof AuthRequiredError) return `${serverName}: needs OAuth (/mcp auth ${serverName})`;
  return `${serverName}: ${error instanceof Error ? error.message : String(error)}`;
}
