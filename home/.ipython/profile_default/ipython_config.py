from prompt_toolkit.styles import defaults as ptk_defaults
from traitlets.config import get_config

BASE00 = "#131914"
BASE01 = "#1D261F"
BASE02 = "#2D382E"
BASE03 = "#556753"
BASE04 = "#87967F"
BASE05 = "#D4DCC2"
BASE06 = "#E7EED3"
BASE07 = "#F5F9EA"
BASE08 = "#DF867A"
BASE09 = "#EDA665"
BASE0A = "#DAC05B"
BASE0B = "#84B87E"
BASE0C = "#63AFA0"
BASE0D = "#97BACC"
BASE0E = "#B89CC1"
BASE0F = "#AA7466"

c = get_config()
c.TerminalInteractiveShell.enable_tip = False
c.TerminalInteractiveShell.true_color = True
c.InteractiveShell.colors = "jungle"

prompt_toolkit_overrides = {
    "readline-like-completions": f"fg:{BASE05} bg:{BASE01}",
    "matching-bracket.other": f"bg:{BASE02}",
    "matching-bracket.cursor": f"fg:{BASE00} bg:{BASE05}",
    "auto-suggestion": f"fg:{BASE03}",
    "completion-menu": f"fg:{BASE05} bg:{BASE01}",
    "completion-menu.completion": f"fg:{BASE05} bg:{BASE01}",
    "completion-menu.completion.current": f"bg:{BASE03}",
    "completion-menu.meta.completion": f"fg:{BASE05} bg:{BASE01}",
    "completion-menu.meta.completion.current": f"bg:{BASE03}",
    "completion-menu.multi-column-meta": f"fg:{BASE05} bg:{BASE01}",
    "completion-toolbar": f"fg:{BASE05} bg:{BASE01}",
    "completion-toolbar.completion.current": f"bg:{BASE03}",
}

prompt_toolkit_style = dict(ptk_defaults.PROMPT_TOOLKIT_STYLE)
prompt_toolkit_style.update(prompt_toolkit_overrides)
ptk_defaults.PROMPT_TOOLKIT_STYLE = list(prompt_toolkit_style.items())
