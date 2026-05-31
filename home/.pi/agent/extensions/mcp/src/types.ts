import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";

export interface OAuthConfig {
  clientId?: string;
  clientSecret?: string;
  scope?: string;
  redirectUri?: string;
  clientName?: string;
  clientUri?: string;
}

export interface ServerDefinition {
  command?: string;
  args?: string[];
  env?: Record<string, string>;
  cwd?: string;
  url?: string;
  headers?: Record<string, string>;
  oauth?: false | OAuthConfig;
  enable?: boolean | string[];
  disabled?: boolean;
  debug?: boolean;
}

export interface AdapterConfig {
  servers: Record<string, ServerDefinition>;
  loadedFiles: string[];
  agentDir: string;
}

export interface McpConfigFile {
  mcpServers?: Record<string, ServerDefinition>;
}

export interface McpTool {
  name: string;
  title?: string;
  description?: string;
  inputSchema?: Record<string, unknown>;
  [key: string]: unknown;
}

export interface TransportLike {
  close?: () => Promise<void>;
  terminateSession?: () => Promise<void>;
  finishAuth?: (code: string) => Promise<void>;
}

export interface ServerConnection {
  client: import("@modelcontextprotocol/sdk/client/index.js").Client;
  transport: TransportLike;
  definition: ServerDefinition;
  tools: McpTool[];
  instructions?: string;
  lastUsedAt: number;
  inFlight: number;
}

export type ServerState = "disabled" | "configured" | "connected" | "needs-auth" | "failed" | "closed";

export interface ServerStatus {
  state: ServerState;
  tools: number;
  registeredTools: number;
  enabledTools: number | "all";
  error?: string;
  missingTools?: string[];
}

export type { CallToolResult };
