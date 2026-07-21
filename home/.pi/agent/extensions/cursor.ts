import { CustomEditor, type ExtensionAPI, type KeybindingsManager } from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";

// matches the reverse-video cursor block the editor emits
// \x1b[7m  +  one or more non-escape chars  +  \x1b[0m
// using [^\x1b]* to avoid crossing into other escape sequences
const CURSOR_PATTERN = /\x1b\[7m([^\x1b]*)\x1b\[0m/;

class NativeCursorEditor extends CustomEditor {
    override render(width: number): string[] {
        return super.render(width).map((line) => line.replace(CURSOR_PATTERN, "$1"));
    }
}

export default function(pi: ExtensionAPI) {
    pi.on("session_start", (_event, ctx) => {
        ctx.ui.setEditorComponent((tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) => {
            tui.setShowHardwareCursor(true);
            return new NativeCursorEditor(tui, theme, keybindings);
        });
    });
}
