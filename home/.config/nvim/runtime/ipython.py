import base64
import io
import os
import shutil
import sys
from collections.abc import Callable
from typing import Any

import pynvim
from IPython import get_ipython
from IPython.terminal.ipapp import TerminalInteractiveShell

ESC = "\x1b"
PLACEHOLDER = "\U0010eeee"
DIACRITICS = (
    "\u0305\u030d\u030e\u0310\u0312\u033d\u033e\u033f\u0346\u034a"
    "\u034b\u034c\u0350\u0351\u0352\u0357\u035b\u0363\u0364\u0365"
)


def png_handler(data: str) -> str:
    return data


def svg_handler(data: str) -> str | None:
    try:
        import cairosvg

        png_bytes = cairosvg.svg2png(bytestring=data.encode("utf-8"))
        return base64.b64encode(png_bytes).decode("utf-8")

    except Exception as e:
        print(f"Failed to process svg image: {e}")
        return None


def jpg_handler(data: str) -> str | None:
    try:
        from PIL import Image

        raw = base64.b64decode(data)
        img = Image.open(io.BytesIO(raw)).convert("RGBA")
        output = io.BytesIO()
        img.save(output, format="PNG")
        return base64.b64encode(output.getvalue()).decode("utf-8")

    except Exception as e:
        print(f"Failed to process jpg image: {e}")
        return None


def register_mime_renderer(
    shell: TerminalInteractiveShell,
    mime: str,
    renderer: Callable[[Any, dict[str, Any]], Any],
):
    assert shell.display_formatter is not None

    if mime not in shell.display_formatter.active_types:
        shell.display_formatter.active_types.append(mime)

    shell.display_formatter.formatters[mime].enabled = True
    shell.mime_renderers[mime] = renderer


def register_image_renderers(shell: TerminalInteractiveShell, nvim: pynvim.Nvim):
    next_id = 1
    tmux = nvim.exec_lua("return require('utils').detect_tmux()")

    def graphics(body: str) -> str:
        sequence = f"{ESC}_G{body}{ESC}\\"
        if tmux:
            sequence = f"{ESC}Ptmux;" + sequence.replace(ESC, ESC * 2) + f"{ESC}\\"
        return sequence

    def render_image(payload: str):
        nonlocal next_id
        image_id = next_id
        next_id = next_id % 255 + 1
        size = shutil.get_terminal_size()
        cols = max(1, min(size.columns - 3, 80))
        rows = max(1, min(size.lines // 2, len(DIACRITICS)))

        commands = []
        for offset in range(0, len(payload), 4096):
            chunk = payload[offset : offset + 4096]
            more = int(offset + 4096 < len(payload))
            header = f"f=100,t=d,i={image_id},q=2," if offset == 0 else ""
            commands.append(graphics(f"{header}m={more};{chunk}"))
        commands.append(graphics(f"a=p,U=1,i={image_id},c={cols},r={rows},C=1,q=2"))

        if nvim.options["termguicolors"]:
            color = f"{ESC}[38;2;0;0;{image_id}m"
        else:
            color = f"{ESC}[38;5;{image_id}m"

        tail = PLACEHOLDER * (cols - 1)
        lines = [
            f"  {ESC}[0m{color}{PLACEHOLDER}{DIACRITICS[row]}{tail}{ESC}[0m"
            for row in range(rows)
        ]

        sys.stdout.flush()
        nvim.api.ui_send("".join(commands))
        sys.stdout.write("\r\n".join(lines) + "\r\n")
        sys.stdout.flush()

    def image_renderer(handler: Callable[[Any], str | None]):
        def wrapper(data: Any, metadata: dict[str, Any] | None):
            _ = metadata
            payload = handler(data)

            if payload is not None:
                try:
                    render_image(payload)
                except Exception as e:
                    print(f"Failed to display image: {e}")

        return wrapper

    register_mime_renderer(shell, "image/png", image_renderer(png_handler))
    register_mime_renderer(shell, "image/jpeg", image_renderer(jpg_handler))
    register_mime_renderer(shell, "image/svg+xml", image_renderer(svg_handler))


def enable_matplotlib_integration(shell: TerminalInteractiveShell):
    try:
        import matplotlib
        from matplotlib_inline.backend_inline import configure_inline_support

        backend = "module://matplotlib_inline.backend_inline"
        matplotlib.use(backend, force=True)
        configure_inline_support(shell, backend)

    except Exception:
        pass


def startup():
    path = os.environ.get("NVIM")
    shell = get_ipython()
    assert shell is not None
    assert path is not None

    nvim = pynvim.attach("socket", path=path)
    register_image_renderers(shell, nvim)
    enable_matplotlib_integration(shell)


startup()
