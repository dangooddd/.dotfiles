import type { truncateHead } from "@earendil-works/pi-coding-agent";

export type TruncationDetails = ReturnType<typeof truncateHead> & { fullOutputPath: string };
