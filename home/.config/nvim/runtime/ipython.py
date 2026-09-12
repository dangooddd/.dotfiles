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
    def image_renderer(handler: Callable[[Any], str | None]):
        def wrapper(data: Any, metadata: dict[str, Any] | None):
            _ = metadata
            payload = handler(data)

            if payload is not None:
                try:
                    size = shutil.get_terminal_size()
                    cols = max(1, min(size.columns - 3, 80))
                    rows = max(1, min(size.lines // 2, 20))
                    sys.stdout.flush()

                    text = nvim.exec_lua(
                        "return require('ipython').prepare_image(...)",
                        payload,
                        cols,
                        rows,
                    )

                    sys.stdout.write(text)
                    sys.stdout.flush()

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
