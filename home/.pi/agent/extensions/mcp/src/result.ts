import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  formatSize,
  truncateHead,
  type AgentToolResult,
} from "@earendil-works/pi-coding-agent";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";

type PiContent = AgentToolResult<Record<string, unknown>>["content"][number];

export function toPiToolResult(result: CallToolResult, details: Record<string, unknown> = {}): AgentToolResult<Record<string, unknown>> {
  const content = transformMcpContent(result);
  return {
    content: content.length > 0 ? content : [{ type: "text", text: "(empty MCP result)" }],
    details: { ...details, mcp: result },
  };
}

export function textResult(text: string, details: Record<string, unknown> = {}): AgentToolResult<Record<string, unknown>> {
  return {
    content: [{ type: "text", text: truncateForContext(text) }],
    details,
  };
}

function transformMcpContent(result: CallToolResult): PiContent[] {
  const blocks: PiContent[] = [];

  if (result.isError) {
    blocks.push({ type: "text", text: "MCP tool returned an error:" });
  }

  for (const item of (result.content ?? []) as Array<Record<string, unknown>>) {
    if (item.type === "text" && typeof item.text === "string") {
      blocks.push({ type: "text", text: truncateForContext(item.text) });
      continue;
    }

    if (item.type === "image" && typeof item.data === "string") {
      blocks.push({
        type: "image",
        data: item.data,
        mimeType: typeof item.mimeType === "string" ? item.mimeType : "image/png",
      });
      continue;
    }

    if (item.type === "resource") {
      blocks.push({ type: "text", text: truncateForContext(formatResourceContent(item.resource)) });
      continue;
    }

    if (item.type === "resource_link") {
      const name = typeof item.name === "string" ? item.name : "unknown";
      const uri = typeof item.uri === "string" ? item.uri : "(no URI)";
      blocks.push({ type: "text", text: `[Resource Link: ${name}]\nURI: ${uri}` });
      continue;
    }

    if (item.type === "audio") {
      const mime = typeof item.mimeType === "string" ? item.mimeType : "audio/*";
      blocks.push({ type: "text", text: `[Audio content: ${mime}]` });
      continue;
    }

    blocks.push({ type: "text", text: truncateForContext(formatJson(item)) });
  }

  if ("structuredContent" in result && result.structuredContent !== undefined) {
    blocks.push({
      type: "text",
      text: truncateForContext(`Structured content:\n${formatJson(result.structuredContent)}`),
    });
  }

  return blocks;
}

function formatResourceContent(value: unknown): string {
  if (!value || typeof value !== "object") return formatJson(value);
  const resource = value as { uri?: unknown; text?: unknown; blob?: unknown; mimeType?: unknown };
  const uri = typeof resource.uri === "string" ? resource.uri : "(no URI)";
  if (typeof resource.text === "string") return `[Resource: ${uri}]\n${resource.text}`;
  if (typeof resource.blob === "string") {
    const mime = typeof resource.mimeType === "string" ? resource.mimeType : "binary";
    return `[Resource: ${uri}]\n[${mime} blob, ${resource.blob.length} base64 chars]`;
  }
  return `[Resource: ${uri}]\n${formatJson(value)}`;
}

function formatJson(value: unknown): string {
  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return String(value);
  }
}

function truncateForContext(text: string): string {
  const truncation = truncateHead(text, {
    maxLines: DEFAULT_MAX_LINES,
    maxBytes: DEFAULT_MAX_BYTES,
  });

  if (!truncation.truncated) return text;

  let tempFile: string | undefined;
  try {
    const dir = mkdtempSync(join(tmpdir(), "pi-mcp-"));
    tempFile = join(dir, "output.txt");
    writeFileSync(tempFile, text, "utf8");
  } catch {
    tempFile = undefined;
  }

  const note = [
    "",
    `[Output truncated: ${truncation.outputLines} of ${truncation.totalLines} lines, ${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}.${tempFile ? ` Full output saved to: ${tempFile}` : ""}]`,
  ].join("\n");

  return `${truncation.content}${note}`;
}
