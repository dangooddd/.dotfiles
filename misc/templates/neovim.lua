if vim.g.colors_name then
    vim.cmd("highlight clear")
end

vim.g.colors_name = "{name}"

local function hl(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

-- completion
hl("ComplMatchIns", {{}})
hl("Pmenu", {{ fg = "#{base05}", bg = "#{base01}" }})
hl("PmenuExtra", {{ link = "Pmenu" }})
hl("PmenuMatch", {{ fg = "#{base05}", bold = true }})
hl("PmenuKind", {{ link = "Pmenu" }})
hl("PmenuSel", {{ bg = "#{base03}" }})
hl("PmenuExtraSel", {{ link = "PmenuSel" }})
hl("PmenuMatchSel", {{ fg = "#{base05}", bold = true }})
hl("PmenuKindSel", {{ link = "PmenuSel" }})
hl("PmenuSbar", {{ bg = "#{base02}" }})
hl("PmenuThumb", {{ bg = "#{base04}" }})

-- cursor search
hl("CurSearch", {{ fg = "#{base01}", bg = "#{base09}" }})
hl("Cursor", {{ fg = "#{base00}", bg = "#{base05}" }})
hl("CursorColumn", {{ bg = "#{base01}" }})
hl("CursorIM", {{ fg = "#{base00}", bg = "#{base05}" }})
hl("CursorLine", {{ bg = "#{base01}" }})
hl("CursorLineFold", {{ fg = "#{base0C}", bg = "#{base01}" }})
hl("CursorLineNr", {{ fg = "#{base04}", bg = "#{base01}" }})
hl("CursorLineSign", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("IncSearch", {{ fg = "#{base01}", bg = "#{base09}" }})
hl("Search", {{ fg = "#{base01}", bg = "#{base0A}" }})
hl("lCursor", {{ fg = "#{base00}", bg = "#{base05}" }})
hl("MatchParen", {{ bg = "#{base02}" }})

-- diff
hl("DiffAdd", {{ bg = "#{mix(base00, base0B, 0.22)}" }})
hl("DiffChange", {{ bg = "#{mix(base00, base0E, 0.10)}" }})
hl("DiffDelete", {{ bg = "#{mix(base00, base08, 0.22)}" }})
hl("DiffText", {{ bg = "#{mix(base00, base0E, 0.22)}" }})

-- spell
hl("SpellBad", {{ undercurl = true, sp = "#{base08}" }})
hl("SpellCap", {{ undercurl = true, sp = "#{base0D}" }})
hl("SpellLocal", {{ undercurl = true, sp = "#{base0C}" }})
hl("SpellRare", {{ undercurl = true, sp = "#{base0E}" }})

-- status tabs
hl("StatusLine", {{ fg = "#{base04}", bg = "#{base02}" }})
hl("StatusLineNC", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("TabLine", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("TabLineFill", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("TabLineSel", {{ fg = "#{base0B}", bg = "#{base01}" }})
hl("WinBar", {{ fg = "#{base04}", bg = "#{base02}" }})
hl("WinBarNC", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("WinSeparator", {{ fg = "#{base02}", bg = "#{base02}" }})

-- editor ui
hl("ColorColumn", {{ bg = "#{base01}" }})
hl("Conceal", {{ fg = "#{base0D}" }})
hl("Directory", {{ fg = "#{base0D}" }})
hl("EndOfBuffer", {{ fg = "#{base03}" }})
hl("ErrorMsg", {{ fg = "#{base08}" }})
hl("FloatBorder", {{ link = "NormalFloat" }})
hl("FoldColumn", {{ fg = "#{base0C}", bg = "#{base01}" }})
hl("Folded", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("LineNr", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("LineNrAbove", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("LineNrBelow", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("ModeMsg", {{ fg = "#{base0B}" }})
hl("MoreMsg", {{ fg = "#{base0B}" }})
hl("MsgArea", {{ link = "Normal" }})
hl("MsgSeparator", {{ fg = "#{base02}", bg = "#{base02}" }})
hl("NonText", {{ fg = "#{base03}" }})
hl("Normal", {{ fg = "#{base05}", bg = "#{base00}" }})
hl("NormalFloat", {{ fg = "#{base05}", bg = "#{base01}" }})
hl("NormalNC", {{ fg = "#{base05}", bg = "#{base00}" }})
hl("OkMsg", {{ fg = "#{base0B}" }})
hl("Question", {{ fg = "#{base0D}" }})
hl("QuickFixLine", {{ bg = "#{base01}" }})
hl("SignColumn", {{ fg = "#{base03}", bg = "#{base01}" }})
hl("SpecialKey", {{ fg = "#{base03}" }})
hl("StderrMsg", {{ link = "ErrorMsg" }})
hl("StdoutMsg", {{ link = "MsgArea" }})
hl("Substitute", {{ fg = "#{base01}", bg = "#{base0A}" }})
hl("TermCursor", {{ reverse = true }})
hl("TermCursorNC", {{ reverse = true }})
hl("Title", {{ fg = "#{base0D}" }})
hl("FloatTitle", {{ fg = "#{base0D}", bg = "#{base01}" }})
hl("VertSplit", {{ fg = "#{base02}", bg = "#{base02}" }})
hl("Visual", {{ bg = "#{base02}" }})
hl("VisualNOS", {{ fg = "#{base08}" }})
hl("WarningMsg", {{ fg = "#{base09}" }})
hl("Whitespace", {{ fg = "#{base03}" }})
hl("WildMenu", {{ fg = "#{base08}", bg = "#{base0A}" }})

-- syntax
hl("Boolean", {{ fg = "#{base0A}" }})
hl("Character", {{ fg = "#{base08}" }})
hl("Comment", {{ fg = "#{base03}" }})
hl("Conditional", {{ fg = "#{base0E}" }})
hl("Constant", {{ fg = "#{base0A}" }})
hl("Debug", {{ fg = "#{base08}" }})
hl("Define", {{ fg = "#{base0E}" }})
hl("Delimiter", {{ fg = "#{base0F}" }})
hl("Error", {{ fg = "#{base00}", bg = "#{base08}" }})
hl("Exception", {{ fg = "#{base08}" }})
hl("Float", {{ fg = "#{base09}" }})
hl("Function", {{ fg = "#{base0D}" }})
hl("Identifier", {{ fg = "#{base0C}" }})
hl("Ignore", {{ fg = "#{base0C}" }})
hl("Include", {{ fg = "#{base08}" }})
hl("Keyword", {{ fg = "#{base0E}" }})
hl("Label", {{ fg = "#{base0A}" }})
hl("Macro", {{ fg = "#{base08}" }})
hl("Number", {{ fg = "#{base09}" }})
hl("Operator", {{ fg = "#{base05}" }})
hl("PreCondit", {{ fg = "#{base08}" }})
hl("PreProc", {{ fg = "#{base08}" }})
hl("Repeat", {{ fg = "#{base0A}" }})
hl("Special", {{ fg = "#{base09}" }})
hl("SpecialChar", {{ fg = "#{base0F}" }})
hl("SpecialComment", {{ fg = "#{base0C}" }})
hl("Statement", {{ fg = "#{base08}" }})
hl("StorageClass", {{ fg = "#{base0A}" }})
hl("String", {{ fg = "#{base0B}" }})
hl("Structure", {{ fg = "#{base0E}" }})
hl("Underlined", {{ underline = true }})
hl("Tag", {{ fg = "#{base0A}" }})
hl("Todo", {{ fg = "#{base0A}", bg = "#{base01}" }})
hl("Type", {{ fg = "#{base0A}" }})
hl("Typedef", {{ fg = "#{base0A}" }})

-- patch diff
hl("diffAdded", {{ fg = "#{base0B}" }})
hl("diffChanged", {{ fg = "#{base0E}" }})
hl("diffFile", {{ fg = "#{base09}" }})
hl("diffLine", {{ fg = "#{base0C}" }})
hl("diffRemoved", {{ fg = "#{base08}" }})
hl("Added", {{ fg = "#{base0B}" }})
hl("Changed", {{ fg = "#{base0E}" }})
hl("Removed", {{ fg = "#{base08}" }})

-- git commit
hl("gitcommitBranch", {{ fg = "#{base09}", bold = true }})
hl("gitcommitComment", {{ link = "Comment" }})
hl("gitcommitDiscarded", {{ link = "Comment" }})
hl("gitcommitDiscardedFile", {{ fg = "#{base08}", bold = true }})
hl("gitcommitDiscardedType", {{ fg = "#{base0D}" }})
hl("gitcommitHeader", {{ fg = "#{base0E}" }})
hl("gitcommitOverflow", {{ fg = "#{base08}" }})
hl("gitcommitSelected", {{ link = "Comment" }})
hl("gitcommitSelectedFile", {{ fg = "#{base0B}", bold = true }})
hl("gitcommitSelectedType", {{ link = "gitcommitDiscardedType" }})
hl("gitcommitSummary", {{ fg = "#{base0B}" }})
hl("gitcommitUnmergedFile", {{ link = "gitcommitDiscardedFile" }})
hl("gitcommitUnmergedType", {{ link = "gitcommitDiscardedType" }})
hl("gitcommitUntracked", {{ link = "Comment" }})
hl("gitcommitUntrackedFile", {{ fg = "#{base0A}" }})

-- diagnostics
hl("DiagnosticError", {{ fg = "#{base08}" }})
hl("DiagnosticHint", {{ fg = "#{base0C}" }})
hl("DiagnosticInfo", {{ fg = "#{base0D}" }})
hl("DiagnosticOk", {{ fg = "#{base0B}" }})
hl("DiagnosticWarn", {{ fg = "#{base0A}" }})
hl("DiagnosticFloatingError", {{ fg = "#{base08}", bg = "#{base01}" }})
hl("DiagnosticFloatingHint", {{ fg = "#{base0C}", bg = "#{base01}" }})
hl("DiagnosticFloatingInfo", {{ fg = "#{base0D}", bg = "#{base01}" }})
hl("DiagnosticFloatingOk", {{ fg = "#{base0B}", bg = "#{base01}" }})
hl("DiagnosticFloatingWarn", {{ fg = "#{base0A}", bg = "#{base01}" }})
hl("DiagnosticSignError", {{ link = "DiagnosticError" }})
hl("DiagnosticSignHint", {{ link = "DiagnosticHint" }})
hl("DiagnosticSignInfo", {{ link = "DiagnosticInfo" }})
hl("DiagnosticSignOk", {{ link = "DiagnosticOk" }})
hl("DiagnosticSignWarn", {{ link = "DiagnosticWarn" }})
hl("DiagnosticUnderlineError", {{ undercurl = true, sp = "#{base08}" }})
hl("DiagnosticUnderlineHint", {{ undercurl = true, sp = "#{base0C}" }})
hl("DiagnosticUnderlineInfo", {{ undercurl = true, sp = "#{base0D}" }})
hl("DiagnosticUnderlineOk", {{ undercurl = true, sp = "#{base0B}" }})
hl("DiagnosticUnderlineWarn", {{ undercurl = true, sp = "#{base0A}" }})

-- snippets
hl("SnippetTabstop", {{ link = "Visual" }})
hl("SnippetTabstopActive", {{ link = "SnippetTabstop" }})

-- headings
hl("markdownH1", {{ fg = "#{base09}" }})
hl("markdownH2", {{ fg = "#{base0A}" }})
hl("markdownH3", {{ fg = "#{base0B}" }})
hl("markdownH4", {{ fg = "#{base0C}" }})
hl("markdownH5", {{ fg = "#{base0D}" }})
hl("markdownH6", {{ fg = "#{base0F}" }})

-- treesitter
hl("@keyword.return", {{ fg = "#{base08}" }})
hl("@keyword.import", {{ link = "Include" }})
hl("@symbol", {{ fg = "#{base0E}" }})
hl("@variable", {{ fg = "#{base05}" }})
hl("@variable.member", {{ link = "Identifier" }})
hl("@text.strong", {{ bold = true }})
hl("@text.emphasis", {{ italic = true }})
hl("@text.strike", {{ strikethrough = true }})
hl("@text.underline", {{ link = "Underlined" }})
hl("@markup.strong", {{ link = "@text.strong" }})
hl("@markup.italic", {{ link = "@text.emphasis" }})
hl("@markup.strikethrough", {{ link = "@text.strike" }})
hl("@markup.underline", {{ link = "@text.underline" }})
hl("@markup.heading.1", {{ link = "markdownH1" }})
hl("@markup.heading.2", {{ link = "markdownH2" }})
hl("@markup.heading.3", {{ link = "markdownH3" }})
hl("@markup.heading.4", {{ link = "markdownH4" }})
hl("@markup.heading.5", {{ link = "markdownH5" }})
hl("@markup.heading.6", {{ link = "markdownH6" }})
hl("@string.special.vimdoc", {{ link = "SpecialChar" }})
hl("@variable.parameter.vimdoc", {{ fg = "#{base09}" }})
hl("@markup.heading.4.vimdoc", {{ link = "Title" }})

-- lsp
hl("LspReferenceText", {{ bg = "#{base02}" }})
hl("LspReferenceRead", {{ link = "LspReferenceText" }})
hl("LspReferenceWrite", {{ link = "LspReferenceText" }})
hl("LspSignatureActiveParameter", {{ link = "LspReferenceText" }})
hl("LspCodeLens", {{ link = "Comment" }})
hl("LspCodeLensSeparator", {{ link = "Comment" }})
hl("@lsp.type.variable", {{ fg = "#{base05}" }})
hl("@lsp.mod.deprecated", {{ fg = "#{base08}" }})

-- terminal colors
vim.g.terminal_color_0 = "#{base00}"
vim.g.terminal_color_1 = "#{base08}"
vim.g.terminal_color_2 = "#{base0B}"
vim.g.terminal_color_3 = "#{base0A}"
vim.g.terminal_color_4 = "#{base0D}"
vim.g.terminal_color_5 = "#{base0E}"
vim.g.terminal_color_6 = "#{base0C}"
vim.g.terminal_color_7 = "#{base05}"
vim.g.terminal_color_8 = "#{base03}"
vim.g.terminal_color_9 = "#{base08}"
vim.g.terminal_color_10 = "#{base0B}"
vim.g.terminal_color_11 = "#{base0A}"
vim.g.terminal_color_12 = "#{base0D}"
vim.g.terminal_color_13 = "#{base0E}"
vim.g.terminal_color_14 = "#{base0C}"
vim.g.terminal_color_15 = "#{base07}"
