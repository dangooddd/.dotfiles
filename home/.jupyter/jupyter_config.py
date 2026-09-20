import shutil
from pathlib import Path

c.LabApp.custom_css = True
c.JupyterNotebookApp.custom_css = True

c.ServerApp.terminado_settings = {
    "shell_command": [
        shutil.which("bash"),
        "--rcfile",
        str(Path.home() / ".jupyter/terminal.sh"),
        "-i",
    ],
}

c.LanguageServerManager.language_servers = {
    "ty": {
        "version": 2,
        "argv": ["ty", "server"],
        "languages": ["python"],
        "mime_types": ["text/python", "text/x-python", "text/x-ipython"],
        "display_name": "ty",
        "requires_documents_on_disk": False,
    },
}
