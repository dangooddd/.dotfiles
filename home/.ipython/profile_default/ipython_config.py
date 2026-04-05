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

c = get_config()

c.TerminalInteractiveShell.enable_tip = False
c.TerminalInteractiveShell.true_color = True
c.TerminalInteractiveShell.highlighting_style_overrides = {
    Token.Text: f"fg:{BASE05} bg:{BASE00}",
    Token.Whitespace: f"fg:{BASE05} bg:{BASE00}",
    Token.Error: f"fg:{BASE00} bg:{BASE08}",
    Token.Comment: f"fg:{BASE03}",
    Token.Comment.Preproc: f"fg:{BASE08}",
    Token.Comment.PreprocFile: f"fg:{BASE08}",
    Token.Comment.Special: f"fg:{BASE0C}",
    Token.Keyword: f"fg:{BASE0E}",
    Token.Keyword.Constant: f"fg:{BASE0A}",
    Token.Keyword.Namespace: f"fg:{BASE08}",
    Token.Keyword.Type: f"fg:{BASE0A}",
    Token.Operator: f"fg:{BASE05}",
    Token.Operator.Word: f"fg:{BASE05}",
    Token.Punctuation: f"fg:{BASE0F}",
    Token.Name: f"fg:{BASE05} bg:{BASE00}",
    Token.Name.Attribute: f"fg:{BASE0C}",
    Token.Name.Builtin: f"fg:{BASE09}",
    Token.Name.Builtin.Pseudo: f"fg:{BASE09}",
    Token.Name.Class: f"fg:{BASE0A}",
    Token.Name.Constant: f"fg:{BASE0A}",
    Token.Name.Decorator: f"fg:{BASE08}",
    Token.Name.Exception: f"fg:{BASE0A}",
    Token.Name.Function: f"fg:{BASE0D}",
    Token.Name.Label: f"fg:{BASE0A}",
    Token.Name.Namespace: f"fg:{BASE0E}",
    Token.Name.Tag: f"fg:{BASE0A}",
    Token.Name.Variable: f"fg:{BASE05}",
    Token.Name.Variable.Magic: f"fg:{BASE09}",
    Token.Literal.String: f"fg:{BASE0B}",
    Token.Literal.String.Char: f"fg:{BASE08}",
    Token.Literal.String.Doc: f"fg:{BASE0B}",
    Token.Literal.String.Escape: f"fg:{BASE0F}",
    Token.Literal.String.Interpol: f"fg:{BASE0F}",
    Token.Literal.String.Regex: f"fg:{BASE0B}",
    Token.Literal.Number: f"fg:{BASE09}",
    Token.Literal.Number.Float: f"fg:{BASE09}",
    Token.Generic.Deleted: f"fg:{BASE08} bg:{BASE01}",
    Token.Generic.Inserted: f"fg:{BASE0B} bg:{BASE01}",
    Token.Generic.Error: f"fg:{BASE00} bg:{BASE08}",
    Token.Generic.Output: f"fg:{BASE03}",
    Token.Prompt: f"fg:{BASE03}",
    Token.PromptNum: f"fg:{BASE09}",
    Token.OutPrompt: f"fg:{BASE03}",
    Token.OutPromptNum: f"fg:{BASE09}",
}

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
