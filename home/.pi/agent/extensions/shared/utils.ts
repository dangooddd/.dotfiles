import {
    DEFAULT_MAX_BYTES,
    DEFAULT_MAX_LINES,
    formatSize,
    truncateHead,
} from "@earendil-works/pi-coding-agent";
import { mkdtemp, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { TruncationDetails } from "./types.ts";

export async function readJson(path: string) {
    try {
        return JSON.parse(await readFile(path, "utf8"));
    } catch (error) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") return {};
        throw error;
    }
}

export function errorMessage(error: unknown) {
    return error instanceof Error ? error.message : String(error);
}

export function truncationMarker(truncation: TruncationDetails) {
    const warnings = [`Full output: ${truncation.fullOutputPath}`];

    if (truncation.truncatedBy === "lines") {
        warnings.push(`Truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines`);
    } else {
        const limit = formatSize(truncation.maxBytes ?? DEFAULT_MAX_BYTES);
        warnings.push(`Truncated: ${truncation.outputLines} lines shown (${limit} limit)`);
    }

    return `[${warnings.join(". ")}]`;
}

export async function truncateOutput(
    output: string,
    tempPrefix: string,
    fileName: string,
): Promise<{ text: string; truncation?: TruncationDetails }> {
    const truncated = truncateHead(output, {
        maxBytes: DEFAULT_MAX_BYTES,
        maxLines: DEFAULT_MAX_LINES,
    });

    let text = truncated.content;
    if (!truncated.truncated) return { text };

    const outputDir = await mkdtemp(join(tmpdir(), tempPrefix));
    const fullOutputPath = join(outputDir, fileName);
    await writeFile(fullOutputPath, output, { encoding: "utf8", mode: 0o600 });

    const truncation = { ...truncated, fullOutputPath };
    text += `\n\n${truncationMarker(truncation)}`;
    return { text, truncation };
}

export async function mapLimit<T, R>(items: T[], limit: number, fn: (item: T) => Promise<R>): Promise<R[]> {
    limit = Math.max(1, limit);
    const results: R[] = [];
    let next = 0;

    async function worker() {
        while (next < items.length) {
            const index = next++;
            results[index] = await fn(items[index]!);
        }
    }

    await Promise.all(Array.from({ length: Math.min(limit, items.length) }, () => worker()));
    return results;
}

export function expandEnv(s: string) {
    return s.replace(
        /\{env:([A-Z0-9_]+)\}|\$\{([A-Z0-9_]+)\}|\$([A-Z0-9_]+)/gi,
        (_, a, b, c) => process.env[a || b || c] ?? "",
    );
}
