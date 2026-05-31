import { existsSync, readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import type { AdapterConfig, McpConfigFile, ServerDefinition } from "./types.js";
import { expandHome, getAgentDir } from "./paths.js";

export function loadConfig(cwd = process.cwd(), agentDir = getAgentDir()): AdapterConfig {
  const files = [
    join(process.env.XDG_CONFIG_HOME ?? join(process.env.HOME ?? "", ".config"), "mcp", "mcp.json"),
    join(agentDir, "mcp.json"),
    join(cwd, ".mcp.json"),
    join(cwd, ".pi", "mcp.json"),
  ];

  const loadedFiles: string[] = [];
  const servers: Record<string, ServerDefinition> = {};

  for (const file of files) {
    if (!existsSync(file)) continue;
    const parsed = readConfigFile(file);
    loadedFiles.push(file);

    for (const [name, definition] of Object.entries(parsed.mcpServers ?? {})) {
      const normalized = normalizeServerDefinition(definition, dirname(file));
      servers[name] = { ...(servers[name] ?? {}), ...normalized };
    }
  }

  return {
    servers: Object.fromEntries(Object.entries(servers).filter(([, server]) => !server.disabled)),
    loadedFiles,
    agentDir,
  };
}

function readConfigFile(path: string): McpConfigFile {
  const raw = readFileSync(path, "utf8");
  const stripped = stripJsonComments(raw);
  const parsed = JSON.parse(stripped) as McpConfigFile;
  if (!parsed || typeof parsed !== "object") return {};
  return parsed;
}

function normalizeServerDefinition(definition: ServerDefinition, configDir: string): ServerDefinition {
  const normalized: ServerDefinition = { ...definition };

  if (normalized.cwd) normalized.cwd = resolveCwd(normalized.cwd, configDir);
  if (normalized.command) normalized.command = interpolateEnv(normalized.command);
  if (normalized.args) normalized.args = normalized.args.map((arg) => interpolateEnv(arg));
  if (normalized.env) normalized.env = interpolateRecord(normalized.env);
  if (normalized.url) normalized.url = interpolateEnv(normalized.url);
  if (normalized.headers) normalized.headers = interpolateRecord(normalized.headers);

  if (normalized.oauth && typeof normalized.oauth === "object") {
    normalized.oauth = {
      ...normalized.oauth,
      clientId: normalized.oauth.clientId ? interpolateEnv(normalized.oauth.clientId) : undefined,
      clientSecret: normalized.oauth.clientSecret ? interpolateEnv(normalized.oauth.clientSecret) : undefined,
      scope: normalized.oauth.scope ? interpolateEnv(normalized.oauth.scope) : undefined,
      redirectUri: normalized.oauth.redirectUri ? interpolateEnv(normalized.oauth.redirectUri) : undefined,
      clientName: normalized.oauth.clientName ? interpolateEnv(normalized.oauth.clientName) : undefined,
      clientUri: normalized.oauth.clientUri ? interpolateEnv(normalized.oauth.clientUri) : undefined,
    };
  }

  return normalized;
}

const ENV_PATTERN = /\$\{([A-Za-z_][A-Za-z0-9_]*)(?::-([^}]*))?\}/g;

export function interpolateEnv(value: string): string {
  return value.replace(ENV_PATTERN, (_match, key: string, defaultValue: string | undefined) => {
    const envValue = process.env[key];
    return envValue !== undefined && envValue !== "" ? envValue : defaultValue ?? "";
  });
}

export function buildProcessEnv(env?: Record<string, string>): Record<string, string> {
  const merged: Record<string, string> = {};
  for (const [key, value] of Object.entries(process.env)) {
    if (typeof value === "string") merged[key] = value;
  }
  return { ...merged, ...(env ?? {}) };
}

function interpolateRecord(record: Record<string, string>): Record<string, string> {
  return Object.fromEntries(Object.entries(record).map(([key, value]) => [key, interpolateEnv(value)]));
}

function resolveCwd(cwd: string, baseDir: string): string {
  return resolve(baseDir, interpolateEnv(expandHome(cwd)));
}

export function stripJsonComments(source: string): string {
  let out = "";
  let inString = false;
  let stringQuote = "";
  let escaped = false;

  for (let i = 0; i < source.length; i++) {
    const ch = source[i];
    const next = source[i + 1];

    if (inString) {
      out += ch;
      if (escaped) escaped = false;
      else if (ch === "\\") escaped = true;
      else if (ch === stringQuote) {
        inString = false;
        stringQuote = "";
      }
      continue;
    }

    if (ch === '"' || ch === "'") {
      inString = true;
      stringQuote = ch;
      out += ch;
      continue;
    }

    if (ch === "/" && next === "/") {
      while (i < source.length && source[i] !== "\n") i++;
      out += "\n";
      continue;
    }

    if (ch === "/" && next === "*") {
      i += 2;
      while (i < source.length && !(source[i] === "*" && source[i + 1] === "/")) i++;
      i++;
      continue;
    }

    out += ch;
  }

  return out;
}
