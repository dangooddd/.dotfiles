import { existsSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";

export function getAgentDir(): string {
  return process.env.PI_CODING_AGENT_DIR
    ? resolve(expandHome(process.env.PI_CODING_AGENT_DIR))
    : join(homedir(), ".pi", "agent");
}

export function expandHome(input: string): string {
  if (input === "~") return homedir();
  if (input.startsWith("~/")) return join(homedir(), input.slice(2));
  return input;
}

export function ensureDir(path: string): void {
  if (!existsSync(path)) mkdirSync(path, { recursive: true });
}

export function ensureParentDir(path: string): void {
  ensureDir(dirname(path));
}

export function sanitizeFileName(name: string): string {
  return name.replace(/[^a-zA-Z0-9_.-]/g, "_");
}

export function adapterDataDir(agentDir = getAgentDir()): string {
  return join(agentDir, "mcp");
}

export function authDataDir(agentDir = getAgentDir()): string {
  return join(adapterDataDir(agentDir), "oauth");
}
