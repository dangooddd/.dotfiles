import type { OAuthClientProvider } from "@modelcontextprotocol/sdk/client/auth.js";
import { UnauthorizedError } from "@modelcontextprotocol/sdk/client/auth.js";
import type {
  OAuthClientInformation,
  OAuthClientInformationFull,
  OAuthClientMetadata,
  OAuthTokens,
} from "@modelcontextprotocol/sdk/shared/auth.js";
import { spawn } from "node:child_process";
import { randomBytes } from "node:crypto";
import { existsSync, readFileSync, writeFileSync, chmodSync, rmSync } from "node:fs";
import { createServer, type IncomingMessage, type Server, type ServerResponse } from "node:http";
import { join } from "node:path";
import { authDataDir, ensureDir, ensureParentDir, sanitizeFileName } from "./paths.js";

export interface BrowserOAuthProviderOptions {
  serverName: string;
  serverUrl: string;
  redirectUrl?: string;
  clientName?: string;
  clientUri?: string;
  config?: {
    clientId?: string;
    clientSecret?: string;
    scope?: string;
    redirectUri?: string;
    clientName?: string;
    clientUri?: string;
  };
  onRedirect?: (url: URL) => Promise<void> | void;
}

export class BrowserOAuthProvider implements OAuthClientProvider {
  private readonly serverName: string;
  private readonly serverUrl: string;
  private readonly redirectUrlValue?: string;
  private readonly config: NonNullable<BrowserOAuthProviderOptions["config"]>;
  private readonly clientName: string;
  private readonly clientUri?: string;
  private readonly onRedirect?: BrowserOAuthProviderOptions["onRedirect"];

  constructor(options: BrowserOAuthProviderOptions) {
    this.serverName = options.serverName;
    this.serverUrl = options.serverUrl;
    this.redirectUrlValue = options.config?.redirectUri ?? options.redirectUrl;
    this.config = options.config ?? {};
    this.clientName = options.config?.clientName ?? options.clientName ?? "Pi MCP Minimal Adapter";
    this.clientUri = options.config?.clientUri ?? options.clientUri;
    this.onRedirect = options.onRedirect;
  }

  get redirectUrl(): string | undefined {
    return this.redirectUrlValue;
  }

  get clientMetadata(): OAuthClientMetadata {
    if (!this.redirectUrl) {
      throw new Error("redirectUrl is required for OAuth authorization_code flow");
    }

    const metadata: OAuthClientMetadata = {
      client_name: this.clientName,
      redirect_uris: [this.redirectUrl],
      grant_types: ["authorization_code", "refresh_token"],
      response_types: ["code"],
      token_endpoint_auth_method: this.config.clientSecret ? "client_secret_post" : "none",
    };

    if (this.clientUri) metadata.client_uri = this.clientUri;
    if (this.config.scope) metadata.scope = this.config.scope;
    return metadata;
  }

  async clientInformation(): Promise<OAuthClientInformation | undefined> {
    if (this.config.clientId) {
      return {
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
      };
    }

    const entry = getAuthForUrl(this.serverName, this.serverUrl);
    const info = entry?.clientInfo;
    if (!info) return undefined;
    if (info.clientSecretExpiresAt && info.clientSecretExpiresAt < Date.now() / 1000) return undefined;

    return {
      client_id: info.clientId,
      client_secret: info.clientSecret,
    };
  }

  async saveClientInformation(info: OAuthClientInformationFull): Promise<void> {
    updateClientInfo(this.serverName, {
      clientId: info.client_id,
      clientSecret: info.client_secret,
      clientIdIssuedAt: info.client_id_issued_at,
      clientSecretExpiresAt: info.client_secret_expires_at,
    }, this.serverUrl);
  }

  async tokens(): Promise<OAuthTokens | undefined> {
    const entry = getAuthForUrl(this.serverName, this.serverUrl);
    const tokens = entry?.tokens;
    if (!tokens) return undefined;

    return {
      access_token: tokens.accessToken,
      token_type: "Bearer",
      refresh_token: tokens.refreshToken,
      expires_in: tokens.expiresAt ? Math.max(0, Math.floor(tokens.expiresAt - Date.now() / 1000)) : undefined,
      scope: tokens.scope,
    };
  }

  async saveTokens(tokens: OAuthTokens): Promise<void> {
    updateTokens(this.serverName, {
      accessToken: tokens.access_token,
      refreshToken: tokens.refresh_token,
      expiresAt: tokens.expires_in ? Date.now() / 1000 + tokens.expires_in : undefined,
      scope: tokens.scope,
    }, this.serverUrl);
  }

  async redirectToAuthorization(authorizationUrl: URL): Promise<void> {
    if (!this.onRedirect) throw new UnauthorizedError(`OAuth flow required for MCP server "${this.serverName}"`);
    await this.onRedirect(authorizationUrl);
  }

  async saveCodeVerifier(codeVerifier: string): Promise<void> {
    updateCodeVerifier(this.serverName, codeVerifier);
  }

  async codeVerifier(): Promise<string> {
    const entry = getAuthEntry(this.serverName);
    if (!entry?.codeVerifier) throw new Error(`No OAuth code verifier saved for ${this.serverName}`);
    return entry.codeVerifier;
  }

  async saveState(state: string): Promise<void> {
    updateOAuthState(this.serverName, state);
  }

  async state(): Promise<string> {
    const entry = getAuthEntry(this.serverName);
    if (entry?.oauthState) return entry.oauthState;
    if (!this.onRedirect) throw new UnauthorizedError(`OAuth flow required for MCP server "${this.serverName}"`);

    const state = randomBytes(32).toString("hex");
    updateOAuthState(this.serverName, state);
    return state;
  }

  async invalidateCredentials(type: "all" | "client" | "tokens"): Promise<void> {
    if (type === "all") clearAllCredentials(this.serverName);
    if (type === "client") clearClientInfo(this.serverName);
    if (type === "tokens") clearTokens(this.serverName);
  }
}

export interface OAuthCallbackResult {
  code: string;
  state?: string;
}

export interface OAuthCallbackServerOptions {
  preferredPort?: number;
  host?: string;
  path?: string;
  timeoutMs?: number;
  strictPort?: boolean;
}

export class OAuthCallbackServer {
  readonly port: number;
  readonly path: string;
  readonly redirectUrl: string;
  private readonly server: Server;
  private readonly resultPromise: Promise<OAuthCallbackResult>;
  private resolveResult?: (result: OAuthCallbackResult) => void;
  private rejectResult?: (error: Error) => void;
  private timer?: NodeJS.Timeout;

  private constructor(server: Server, host: string, port: number, path: string, timeoutMs: number) {
    this.server = server;
    this.port = port;
    this.path = path;
    this.redirectUrl = `http://${host}:${port}${path}`;
    this.resultPromise = new Promise<OAuthCallbackResult>((resolve, reject) => {
      this.resolveResult = resolve;
      this.rejectResult = reject;
    });
    this.timer = setTimeout(() => {
      this.rejectResult?.(new Error("OAuth callback timed out"));
      void this.close();
    }, timeoutMs);
    this.timer.unref?.();
  }

  static async start(options: OAuthCallbackServerOptions = {}): Promise<OAuthCallbackServer> {
    const path = options.path ?? "/mcp/oauth/callback";
    const host = options.host ?? "127.0.0.1";
    const timeoutMs = options.timeoutMs ?? 180_000;
    const preferredPort = options.preferredPort ?? Number(process.env.MCP_OAUTH_CALLBACK_PORT ?? 19876);

    const candidates = Number.isInteger(preferredPort) && preferredPort > 0
      ? options.strictPort ? [preferredPort] : [preferredPort, 0]
      : [0];

    let lastError: unknown;
    for (const port of candidates) {
      try {
        return await this.tryListen(host, port, path, timeoutMs);
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError instanceof Error ? lastError : new Error("Failed to start OAuth callback server");
  }

  private static async tryListen(host: string, port: number, path: string, timeoutMs: number): Promise<OAuthCallbackServer> {
    let instance: OAuthCallbackServer;

    const server = createServer((req, res) => {
      instance.handle(req, res);
    });

    await new Promise<void>((resolve, reject) => {
      server.once("error", reject);
      server.listen(port, host, () => {
        server.off("error", reject);
        resolve();
      });
    });

    const address = server.address();
    const actualPort = typeof address === "object" && address ? address.port : port;
    instance = new OAuthCallbackServer(server, host, actualPort, path, timeoutMs);
    return instance;
  }

  waitForCallback(): Promise<OAuthCallbackResult> {
    return this.resultPromise;
  }

  async close(): Promise<void> {
    if (this.timer) clearTimeout(this.timer);
    await new Promise<void>((resolve) => {
      this.server.close(() => resolve());
    }).catch(() => undefined);
  }

  private handle(req: IncomingMessage, res: ServerResponse): void {
    const host = req.headers.host ?? `127.0.0.1:${this.port}`;
    const url = new URL(req.url ?? "/", `http://${host}`);

    if (url.pathname !== this.path) {
      res.statusCode = 404;
      res.end("Not found");
      return;
    }

    const error = url.searchParams.get("error");
    if (error) {
      const description = url.searchParams.get("error_description") ?? error;
      this.rejectResult?.(new Error(description));
      res.statusCode = 400;
      res.setHeader("content-type", "text/html; charset=utf-8");
      res.end(renderHtml("OAuth failed", escapeHtml(description)));
      void this.close();
      return;
    }

    const code = url.searchParams.get("code");
    if (!code) {
      this.rejectResult?.(new Error("OAuth callback did not include a code"));
      res.statusCode = 400;
      res.setHeader("content-type", "text/html; charset=utf-8");
      res.end(renderHtml("OAuth failed", "Missing authorization code."));
      void this.close();
      return;
    }

    this.resolveResult?.({ code, state: url.searchParams.get("state") ?? undefined });
    res.statusCode = 200;
    res.setHeader("content-type", "text/html; charset=utf-8");
    res.end(renderHtml("OAuth complete", "You can close this tab and return to Pi."));
    void this.close();
  }
}

export function callbackOptionsFromRedirectUri(redirectUri: string | undefined): OAuthCallbackServerOptions {
  if (!redirectUri) return {};

  const url = new URL(redirectUri);
  if (url.protocol !== "http:") {
    throw new Error("OAuth redirectUri must use http:// for a local callback server");
  }

  const host = url.hostname;
  if (host !== "127.0.0.1" && host !== "localhost") {
    throw new Error("OAuth redirectUri host must be localhost or 127.0.0.1");
  }

  const port = Number.parseInt(url.port, 10);
  if (!Number.isInteger(port) || port <= 0 || port > 65535) {
    throw new Error("OAuth redirectUri must include an explicit port");
  }

  return {
    host,
    preferredPort: port,
    path: url.pathname || "/mcp/oauth/callback",
    strictPort: true,
  };
}

export async function openUrl(url: string): Promise<boolean> {
  const platform = process.platform;
  const command = platform === "darwin" ? "open" : platform === "win32" ? "cmd" : "xdg-open";
  const args = platform === "win32" ? ["/c", "start", "", url] : [url];

  return new Promise<boolean>((resolve) => {
    try {
      const child = spawn(command, args, { detached: true, stdio: "ignore" });
      child.once("error", () => resolve(false));
      child.unref();
      resolve(true);
    } catch {
      resolve(false);
    }
  });
}

interface StoredTokens {
  accessToken: string;
  refreshToken?: string;
  expiresAt?: number;
  scope?: string;
}

interface StoredClientInfo {
  clientId: string;
  clientSecret?: string;
  clientIdIssuedAt?: number;
  clientSecretExpiresAt?: number;
}

interface AuthEntry {
  serverUrl?: string;
  tokens?: StoredTokens;
  clientInfo?: StoredClientInfo;
  codeVerifier?: string;
  oauthState?: string;
  updatedAt?: string;
}

function authPath(serverName: string): string {
  return join(authDataDir(), `${sanitizeFileName(serverName)}.json`);
}

function getAuthEntry(serverName: string): AuthEntry | undefined {
  const file = authPath(serverName);
  if (!existsSync(file)) return undefined;
  try {
    return JSON.parse(readFileSync(file, "utf8")) as AuthEntry;
  } catch {
    return undefined;
  }
}

function getAuthForUrl(serverName: string, serverUrl: string): AuthEntry | undefined {
  const entry = getAuthEntry(serverName);
  if (!entry) return undefined;
  if (entry.serverUrl && normalizeUrl(entry.serverUrl) !== normalizeUrl(serverUrl)) return undefined;
  if (entry.tokens?.expiresAt && entry.tokens.expiresAt <= Date.now() / 1000 && !entry.tokens.refreshToken) {
    return { ...entry, tokens: undefined };
  }
  return entry;
}

function updateAuthEntry(serverName: string, patch: Partial<AuthEntry>): AuthEntry {
  const previous = getAuthEntry(serverName) ?? {};
  const next: AuthEntry = { ...previous, ...patch, updatedAt: new Date().toISOString() };
  writeAuthEntry(serverName, next);
  return next;
}

function updateTokens(serverName: string, tokens: StoredTokens, serverUrl: string): void {
  updateAuthEntry(serverName, { tokens, serverUrl });
}

function updateClientInfo(serverName: string, clientInfo: StoredClientInfo, serverUrl: string): void {
  updateAuthEntry(serverName, { clientInfo, serverUrl });
}

function updateCodeVerifier(serverName: string, codeVerifier: string): void {
  updateAuthEntry(serverName, { codeVerifier });
}

function updateOAuthState(serverName: string, oauthState: string): void {
  updateAuthEntry(serverName, { oauthState });
}

function clearTokens(serverName: string): void {
  const entry = getAuthEntry(serverName);
  if (!entry) return;
  delete entry.tokens;
  writeAuthEntry(serverName, entry);
}

function clearClientInfo(serverName: string): void {
  const entry = getAuthEntry(serverName);
  if (!entry) return;
  delete entry.clientInfo;
  writeAuthEntry(serverName, entry);
}

export function clearAllCredentials(serverName: string): void {
  const file = authPath(serverName);
  if (existsSync(file)) rmSync(file, { force: true });
}

function writeAuthEntry(serverName: string, entry: AuthEntry): void {
  const file = authPath(serverName);
  ensureParentDir(file);
  ensureDir(authDataDir());
  writeFileSync(file, `${JSON.stringify(entry, null, 2)}\n`, { mode: 0o600 });
  try {
    chmodSync(file, 0o600);
  } catch {
    // Some filesystems do not support chmod. The file is still usable.
  }
}

function normalizeUrl(input: string): string {
  try {
    const url = new URL(input);
    url.hash = "";
    return url.toString().replace(/\/$/, "");
  } catch {
    return input.replace(/\/$/, "");
  }
}

function renderHtml(title: string, body: string): string {
  return `<!doctype html><html><head><meta charset="utf-8"><title>${escapeHtml(title)}</title><style>body{font-family:system-ui,sans-serif;max-width:720px;margin:64px auto;padding:0 24px;line-height:1.5}</style></head><body><h1>${escapeHtml(title)}</h1><p>${body}</p></body></html>`;
}

function escapeHtml(input: string): string {
  return input.replace(/[&<>"']/g, (ch) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[ch] ?? ch));
}
