import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { loadConfig } from "./config.js";
import { registerCommands, formatStartupError } from "./commands.js";
import { AuthRequiredError, McpManager, isServerEnabled, publicToolName } from "./manager.js";
import { textResult, toPiToolResult } from "./result.js";
import type { McpTool } from "./types.js";

const BUILTIN_TOOL_NAMES = new Set(["read", "bash", "edit", "write", "grep", "find", "ls"]);

export default async function piMcpMinimalAdapter(pi: ExtensionAPI) {
  const config = loadConfig();
  const manager = new McpManager(config);
  const remoteToPiTool = new Map<string, string>();
  const allocatedPiToolNames = new Set<string>();

  async function registerToolsForServer(serverName: string): Promise<number> {
    const definition = manager.getDefinition(serverName);
    if (!definition || !isServerEnabled(definition)) {
      manager.recordRegisteredTools(serverName, countRegisteredForServer(serverName));
      return 0;
    }

    const connection = manager.getConnection(serverName) ?? await manager.connect(serverName);
    const { tools, missingTools } = manager.filterEnabledTools(serverName, connection.tools);
    let registeredNow = 0;

    for (const tool of tools) {
      const remoteKey = remoteToolKey(serverName, tool.name);
      if (remoteToPiTool.has(remoteKey)) continue;

      const piToolName = allocateToolName(publicToolName(serverName, tool.name));
      remoteToPiTool.set(remoteKey, piToolName);

      pi.registerTool({
        name: piToolName,
        label: `MCP: ${serverName}/${tool.name}`,
        description: `[MCP:${serverName}] ${tool.description ?? tool.title ?? tool.name}`,
        promptSnippet: truncateAtWord(`[MCP:${serverName}] ${tool.description ?? tool.title ?? tool.name}`, 160),
        parameters: Type.Unsafe<Record<string, unknown>>(safeInputSchema(tool.inputSchema)),
        async execute(_toolCallId, params) {
          try {
            const result = await manager.callTool(serverName, tool.name, params as Record<string, unknown> ?? {});
            return toPiToolResult(result, { server: serverName, tool: tool.name, piTool: piToolName });
          } catch (error) {
            if (error instanceof AuthRequiredError) {
              return textResult(error.message, { error: "auth_required", server: serverName, tool: tool.name });
            }
            throw error;
          }
        },
      });

      registeredNow++;
    }

    manager.recordRegisteredTools(serverName, countRegisteredForServer(serverName), missingTools);
    return registeredNow;
  }

  async function eagerLoad(targetServer?: string): Promise<number> {
    const serverNames = targetServer ? [targetServer] : manager.listEnabledServerNames();
    let registered = 0;
    const errors: string[] = [];

    await Promise.all(serverNames.map(async (serverName) => {
      const definition = manager.getDefinition(serverName);
      if (!definition) {
        errors.push(`Unknown MCP server: ${serverName}`);
        return;
      }
      if (!isServerEnabled(definition)) return;

      try {
        await manager.connect(serverName);
        registered += await registerToolsForServer(serverName);
      } catch (error) {
        errors.push(formatStartupError(serverName, error));
      }
    }));

    if (errors.length > 0) {
      console.warn(`MCP minimal adapter startup:\n${errors.join("\n")}`);
    }

    return registered;
  }

  registerCommands(pi, manager, registerToolsForServer, eagerLoad);

  pi.on("session_start", async () => {
    await eagerLoad();
  });

  pi.on("session_shutdown", async () => {
    await manager.closeAll();
  });

  function allocateToolName(baseName: string): string {
    const existing = getExistingToolNames();
    let candidate = baseName;
    let index = 2;

    while (allocatedPiToolNames.has(candidate) || existing.has(candidate)) {
      candidate = `${baseName}_${index++}`;
    }

    allocatedPiToolNames.add(candidate);
    return candidate;
  }

  function getExistingToolNames(): Set<string> {
    const existing = new Set(BUILTIN_TOOL_NAMES);
    for (const tool of pi.getAllTools()) existing.add(tool.name);
    return existing;
  }

  function countRegisteredForServer(serverName: string): number {
    let count = 0;
    for (const key of remoteToPiTool.keys()) {
      if (key.startsWith(`${serverName}\0`)) count++;
    }
    return count;
  }
}

function remoteToolKey(serverName: string, toolName: string): string {
  return `${serverName}\0${toolName}`;
}

function safeInputSchema(schema: McpTool["inputSchema"]): Record<string, unknown> {
  if (!schema || typeof schema !== "object" || Array.isArray(schema)) {
    return { type: "object", additionalProperties: true };
  }
  return schema;
}

function truncateAtWord(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  const slice = text.slice(0, maxLength - 1);
  const lastSpace = slice.lastIndexOf(" ");
  return `${slice.slice(0, lastSpace > 40 ? lastSpace : slice.length).trimEnd()}…`;
}
