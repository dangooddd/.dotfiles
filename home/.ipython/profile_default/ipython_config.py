from IPython.utils.PyColorize import Theme, theme_table
from prompt_toolkit.styles import defaults as ptk_defaults
from pygments.token import Token
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

theme = Theme(
    "custom",
    None,
    {
        Token.Text: BASE05,
        Token.Whitespace: BASE05,
        Token.Error: f"{BASE00} bg:{BASE08}",
        Token.Comment: BASE03,
        Token.Comment.Preproc: BASE08,
        Token.Comment.PreprocFile: BASE08,
        Token.Comment.Special: BASE0C,
        Token.Keyword: BASE0E,
        Token.Keyword.Constant: BASE0A,
        Token.Keyword.Namespace: BASE08,
        Token.Keyword.Type: BASE0A,
        Token.Operator: BASE05,
        Token.Operator.Word: BASE05,
        Token.Punctuation: BASE0F,
        Token.Name: BASE05,
        Token.Name.Attribute: BASE0C,
        Token.Name.Builtin: BASE09,
        Token.Name.Builtin.Pseudo: BASE09,
        Token.Name.Class: BASE0A,
        Token.Name.Constant: BASE0A,
        Token.Name.Decorator: BASE08,
        Token.Name.Exception: BASE0A,
        Token.Name.Function: BASE0D,
        Token.Name.Label: BASE0A,
        Token.Name.Namespace: BASE0E,
        Token.Name.Tag: BASE0A,
        Token.Name.Variable: BASE05,
        Token.Name.Variable.Magic: BASE09,
        Token.Literal.String: BASE0B,
        Token.Literal.String.Char: BASE08,
        Token.Literal.String.Doc: BASE0B,
        Token.Literal.String.Escape: BASE0F,
        Token.Literal.String.Interpol: BASE0F,
        Token.Literal.String.Regex: BASE0B,
        Token.Literal.Number: BASE09,
        Token.Literal.Number.Float: BASE09,
        Token.Generic.Deleted: f"{BASE08} bg:{BASE01}",
        Token.Generic.Inserted: f"{BASE0B} bg:{BASE01}",
        Token.Generic.Error: f"{BASE00} bg:{BASE08}",
        Token.Generic.Output: BASE03,
        Token.Prompt: BASE03,
        Token.PromptNum: BASE09,
        Token.OutPrompt: BASE03,
        Token.OutPromptNum: BASE09,
        Token.Header: BASE08,
        Token.ExcName: BASE08,
        Token.Topline: BASE08,
        Token.Lineno: BASE03,
        Token.LinenoEm: f"bold {BASE0B}",
        Token.Filename: BASE0C,
        Token.FilenameEm: f"bold {BASE0C}",
        Token.VName: BASE0C,
        Token.ValEm: BASE09,
        Token.Normal: BASE05,
        Token.NormalEm: f"bold {BASE05}",
        Token.Caret: BASE08,
        Token.Line: BASE05,
        Token.TB.Name: BASE0D,
        Token.TB.NameEm: f"bold {BASE0D}",
        Token.Breakpoint: BASE08,
        Token.Breakpoint.Enabled: BASE08,
        Token.Breakpoint.Disabled: BASE03,
        Token.TbHighlight: f"bg:{BASE02}",
    },
)

theme_table["custom"] = theme
c = get_config()
c.TerminalInteractiveShell.enable_tip = False
c.TerminalInteractiveShell.true_color = True
c.InteractiveShell.colors = "custom"

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
