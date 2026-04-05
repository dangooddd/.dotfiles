import base64
import io
import os
from collections.abc import Callable
from queue import Queue
from threading import Event, Thread
from typing import Any

import pynvim
from IPython import get_ipython
from IPython.terminal.ipapp import TerminalInteractiveShell


def png_handler(data: str):
    return data


def svg_handler(data: str):
    try:
        import cairosvg

        png_bytes = cairosvg.svg2png(bytestring=data.encode("utf-8"))
        return base64.b64encode(png_bytes).decode("utf-8")
    except Exception as e:
        print(f"Failed to process svg image: {e}")
        return None


def jpg_handler(data: str):
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


def image_worker(queue: Queue[str], dead: Event, nvim: pynvim.Nvim) -> None:
    try:
        while True:
            data = queue.get()

            try:
                nvim.exec_lua("require('ipython').image_handler(...)", data)
            except Exception as e:
                print(f"Failed to display image: {e}")
            finally:
                queue.task_done()

    except Exception as e:
        print(f"Image worker died: {e}")
        dead.set()


def register_mime_renderer(
    shell: TerminalInteractiveShell,
    mime: str,
    handler: Callable[[Any, dict[str, Any]], Any],
):
    assert shell.display_formatter is not None

    if mime not in shell.display_formatter.active_types:
        shell.display_formatter.active_types.append(mime)

    shell.display_formatter.formatters[mime].enabled = True
    shell.mime_renderers[mime] = handler


def install_image_handlers(shell: TerminalInteractiveShell, queue: Queue[str]) -> None:
    def wrap_handler(handler: Callable[[Any], str]):
        def wrapped(data: Any, metadata: dict[str, Any] | None):
            _ = metadata
            payload = handler(data)
            if payload is not None:
                queue.put(payload)

        return wrapped

    register_mime_renderer(shell, "image/png", wrap_handler(png_handler))
    register_mime_renderer(shell, "image/jpeg", wrap_handler(jpg_handler))
    register_mime_renderer(shell, "image/svg+xml", wrap_handler(svg_handler))


def enable_matplotlib_backend(shell: TerminalInteractiveShell) -> None:
    try:
        import matplotlib
        from matplotlib_inline.backend_inline import configure_inline_support

        backend = "module://matplotlib_inline.backend_inline"
        matplotlib.use(backend, force=True)
        configure_inline_support(shell, backend)

    except Exception:
        pass


def startup() -> None:
    path = os.environ.get("NVIM")
    shell = get_ipython()
    assert shell is not None
    assert path is not None

    nvim = pynvim.attach("socket", path=path)
    queue: Queue[str] = Queue()
    dead = Event()
    thread = Thread(target=image_worker, args=(queue, dead, nvim), daemon=True)

    try:
        enable_matplotlib_backend(shell)
        install_image_handlers(shell, queue)
        thread.start()

    except Exception as e:
        nvim.exec_lua("vim.notify(..., vim.log.levels.ERROR)", str(e))


startup()
