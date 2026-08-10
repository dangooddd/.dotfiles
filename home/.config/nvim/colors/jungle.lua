if vim.g.colors_name then
    vim.cmd("highlight clear")
end

vim.g.colors_name = "jungle"

local function hl(name, val)
    vim.api.nvim_set_hl(0, name, val)
end

-- completion
hl("ComplMatchIns", {})
hl("Pmenu", { fg = "#D4DCC2", bg = "#1D261F" })
hl("PmenuExtra", { link = "Pmenu" })
hl("PmenuMatch", { fg = "#D4DCC2", bold = true })
hl("PmenuKind", { link = "Pmenu" })
hl("PmenuSel", { bg = "#556753" })
hl("PmenuExtraSel", { link = "PmenuSel" })
hl("PmenuMatchSel", { fg = "#D4DCC2", bold = true })
hl("PmenuKindSel", { link = "PmenuSel" })
hl("PmenuSbar", { bg = "#2D382E" })
hl("PmenuThumb", { bg = "#87967F" })

-- cursor search
hl("CurSearch", { fg = "#1D261F", bg = "#EDA665" })
hl("Cursor", { fg = "#131914", bg = "#D4DCC2" })
hl("CursorColumn", { bg = "#1D261F" })
hl("CursorIM", { fg = "#131914", bg = "#D4DCC2" })
hl("CursorLine", { bg = "#1D261F" })
hl("CursorLineFold", { fg = "#63AFA0", bg = "#1D261F" })
hl("CursorLineNr", { fg = "#87967F", bg = "#1D261F" })
hl("CursorLineSign", { fg = "#556753", bg = "#1D261F" })
hl("IncSearch", { fg = "#1D261F", bg = "#EDA665" })
hl("Search", { fg = "#1D261F", bg = "#DAC05B" })
hl("lCursor", { fg = "#131914", bg = "#D4DCC2" })
hl("MatchParen", { bg = "#2D382E" })

-- diff
hl("DiffAdd", { bg = "#2C3C2B" })
hl("DiffChange", { bg = "#242625" })
hl("DiffDelete", { bg = "#40312A" })
hl("DiffText", { bg = "#37363A" })

-- spell
hl("SpellBad", { undercurl = true, sp = "#DF867A" })
hl("SpellCap", { undercurl = true, sp = "#97BACC" })
hl("SpellLocal", { undercurl = true, sp = "#63AFA0" })
hl("SpellRare", { undercurl = true, sp = "#B89CC1" })

-- status tabs
hl("StatusLine", { fg = "#87967F", bg = "#2D382E" })
hl("StatusLineNC", { fg = "#556753", bg = "#1D261F" })
hl("TabLine", { fg = "#556753", bg = "#1D261F" })
hl("TabLineFill", { fg = "#556753", bg = "#1D261F" })
hl("TabLineSel", { fg = "#84B87E", bg = "#1D261F" })
hl("WinBar", { fg = "#87967F", bg = "#2D382E" })
hl("WinBarNC", { fg = "#556753", bg = "#1D261F" })
hl("WinSeparator", { fg = "#2D382E", bg = "#2D382E" })

-- editor ui
hl("ColorColumn", { bg = "#1D261F" })
hl("Conceal", { fg = "#97BACC" })
hl("Directory", { fg = "#97BACC" })
hl("EndOfBuffer", { fg = "#556753" })
hl("ErrorMsg", { fg = "#DF867A" })
hl("FloatBorder", { link = "NormalFloat" })
hl("FoldColumn", { fg = "#63AFA0", bg = "#1D261F" })
hl("Folded", { fg = "#556753", bg = "#1D261F" })
hl("LineNr", { fg = "#556753", bg = "#1D261F" })
hl("LineNrAbove", { fg = "#556753", bg = "#1D261F" })
hl("LineNrBelow", { fg = "#556753", bg = "#1D261F" })
hl("ModeMsg", { fg = "#84B87E" })
hl("MoreMsg", { fg = "#84B87E" })
hl("MsgArea", { link = "Normal" })
hl("MsgSeparator", { fg = "#2D382E", bg = "#2D382E" })
hl("NonText", { fg = "#556753" })
hl("Normal", { fg = "#D4DCC2", bg = "#131914" })
hl("NormalFloat", { fg = "#D4DCC2", bg = "#1D261F" })
hl("NormalNC", { fg = "#D4DCC2", bg = "#131914" })
hl("OkMsg", { fg = "#84B87E" })
hl("Question", { fg = "#97BACC" })
hl("QuickFixLine", { bg = "#1D261F" })
hl("SignColumn", { fg = "#556753", bg = "#1D261F" })
hl("SpecialKey", { fg = "#556753" })
hl("StderrMsg", { link = "ErrorMsg" })
hl("StdoutMsg", { link = "MsgArea" })
hl("Substitute", { fg = "#1D261F", bg = "#DAC05B" })
hl("TermCursor", { reverse = true })
hl("TermCursorNC", { reverse = true })
hl("Title", { fg = "#97BACC" })
hl("FloatTitle", { fg = "#97BACC", bg = "#1D261F" })
hl("VertSplit", { fg = "#2D382E", bg = "#2D382E" })
hl("Visual", { bg = "#2D382E" })
hl("VisualNOS", { fg = "#DF867A" })
hl("WarningMsg", { fg = "#EDA665" })
hl("Whitespace", { fg = "#556753" })
hl("WildMenu", { fg = "#DF867A", bg = "#DAC05B" })

-- syntax
hl("Boolean", { fg = "#DAC05B" })
hl("Character", { fg = "#DF867A" })
hl("Comment", { fg = "#556753" })
hl("Conditional", { fg = "#B89CC1" })
hl("Constant", { fg = "#DAC05B" })
hl("Debug", { fg = "#DF867A" })
hl("Define", { fg = "#B89CC1" })
hl("Delimiter", { fg = "#AA7466" })
hl("Error", { fg = "#131914", bg = "#DF867A" })
hl("Exception", { fg = "#DF867A" })
hl("Float", { fg = "#EDA665" })
hl("Function", { fg = "#97BACC" })
hl("Identifier", { fg = "#63AFA0" })
hl("Ignore", { fg = "#63AFA0" })
hl("Include", { fg = "#DF867A" })
hl("Keyword", { fg = "#B89CC1" })
hl("Label", { fg = "#DAC05B" })
hl("Macro", { fg = "#DF867A" })
hl("Number", { fg = "#EDA665" })
hl("Operator", { fg = "#D4DCC2" })
hl("PreCondit", { fg = "#DF867A" })
hl("PreProc", { fg = "#DF867A" })
hl("Repeat", { fg = "#DAC05B" })
hl("Special", { fg = "#EDA665" })
hl("SpecialChar", { fg = "#AA7466" })
hl("SpecialComment", { fg = "#63AFA0" })
hl("Statement", { fg = "#DF867A" })
hl("StorageClass", { fg = "#DAC05B" })
hl("String", { fg = "#84B87E" })
hl("Structure", { fg = "#B89CC1" })
hl("Underlined", { underline = true })
hl("Tag", { fg = "#DAC05B" })
hl("Todo", { fg = "#DAC05B", bg = "#1D261F" })
hl("Type", { fg = "#DAC05B" })
hl("Typedef", { fg = "#DAC05B" })

-- patch diff
hl("diffAdded", { fg = "#84B87E" })
hl("diffChanged", { fg = "#B89CC1" })
hl("diffFile", { fg = "#EDA665" })
hl("diffLine", { fg = "#63AFA0" })
hl("diffRemoved", { fg = "#DF867A" })
hl("Added", { fg = "#84B87E" })
hl("Changed", { fg = "#B89CC1" })
hl("Removed", { fg = "#DF867A" })

-- git commit
hl("gitcommitBranch", { fg = "#EDA665", bold = true })
hl("gitcommitComment", { link = "Comment" })
hl("gitcommitDiscarded", { link = "Comment" })
hl("gitcommitDiscardedFile", { fg = "#DF867A", bold = true })
hl("gitcommitDiscardedType", { fg = "#97BACC" })
hl("gitcommitHeader", { fg = "#B89CC1" })
hl("gitcommitOverflow", { fg = "#DF867A" })
hl("gitcommitSelected", { link = "Comment" })
hl("gitcommitSelectedFile", { fg = "#84B87E", bold = true })
hl("gitcommitSelectedType", { link = "gitcommitDiscardedType" })
hl("gitcommitSummary", { fg = "#84B87E" })
hl("gitcommitUnmergedFile", { link = "gitcommitDiscardedFile" })
hl("gitcommitUnmergedType", { link = "gitcommitDiscardedType" })
hl("gitcommitUntracked", { link = "Comment" })
hl("gitcommitUntrackedFile", { fg = "#DAC05B" })

-- diagnostics
hl("DiagnosticError", { fg = "#DF867A" })
hl("DiagnosticHint", { fg = "#63AFA0" })
hl("DiagnosticInfo", { fg = "#97BACC" })
hl("DiagnosticOk", { fg = "#84B87E" })
hl("DiagnosticWarn", { fg = "#DAC05B" })
hl("DiagnosticFloatingError", { fg = "#DF867A", bg = "#1D261F" })
hl("DiagnosticFloatingHint", { fg = "#63AFA0", bg = "#1D261F" })
hl("DiagnosticFloatingInfo", { fg = "#97BACC", bg = "#1D261F" })
hl("DiagnosticFloatingOk", { fg = "#84B87E", bg = "#1D261F" })
hl("DiagnosticFloatingWarn", { fg = "#DAC05B", bg = "#1D261F" })
hl("DiagnosticSignError", { link = "DiagnosticError" })
hl("DiagnosticSignHint", { link = "DiagnosticHint" })
hl("DiagnosticSignInfo", { link = "DiagnosticInfo" })
hl("DiagnosticSignOk", { link = "DiagnosticOk" })
hl("DiagnosticSignWarn", { link = "DiagnosticWarn" })
hl("DiagnosticUnderlineError", { undercurl = true, sp = "#DF867A" })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = "#63AFA0" })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = "#97BACC" })
hl("DiagnosticUnderlineOk", { undercurl = true, sp = "#84B87E" })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = "#DAC05B" })

-- snippets
hl("SnippetTabstop", { link = "Visual" })
hl("SnippetTabstopActive", { link = "SnippetTabstop" })

-- headings
hl("markdownH1", { fg = "#EDA665" })
hl("markdownH2", { fg = "#DAC05B" })
hl("markdownH3", { fg = "#84B87E" })
hl("markdownH4", { fg = "#63AFA0" })
hl("markdownH5", { fg = "#97BACC" })
hl("markdownH6", { fg = "#AA7466" })

-- treesitter
hl("@keyword.return", { fg = "#DF867A" })
hl("@keyword.import", { link = "Include" })
hl("@symbol", { fg = "#B89CC1" })
hl("@variable", { fg = "#D4DCC2" })
hl("@variable.member", { link = "Identifier" })
hl("@text.strong", { bold = true })
hl("@text.emphasis", { italic = true })
hl("@text.strike", { strikethrough = true })
hl("@text.underline", { link = "Underlined" })
hl("@markup.strong", { link = "@text.strong" })
hl("@markup.italic", { link = "@text.emphasis" })
hl("@markup.strikethrough", { link = "@text.strike" })
hl("@markup.underline", { link = "@text.underline" })
hl("@markup.heading.1", { link = "markdownH1" })
hl("@markup.heading.2", { link = "markdownH2" })
hl("@markup.heading.3", { link = "markdownH3" })
hl("@markup.heading.4", { link = "markdownH4" })
hl("@markup.heading.5", { link = "markdownH5" })
hl("@markup.heading.6", { link = "markdownH6" })
hl("@string.special.vimdoc", { link = "SpecialChar" })
hl("@variable.parameter.vimdoc", { fg = "#EDA665" })
hl("@markup.heading.4.vimdoc", { link = "Title" })

-- lsp
hl("LspReferenceText", { bg = "#2D382E" })
hl("LspReferenceRead", { link = "LspReferenceText" })
hl("LspReferenceWrite", { link = "LspReferenceText" })
hl("LspSignatureActiveParameter", { link = "LspReferenceText" })
hl("LspCodeLens", { link = "Comment" })
hl("LspCodeLensSeparator", { link = "Comment" })
hl("@lsp.type.variable", { fg = "#D4DCC2" })
hl("@lsp.mod.deprecated", { fg = "#DF867A" })

-- terminal colors
vim.g.terminal_color_0 = "#131914"
vim.g.terminal_color_1 = "#DF867A"
vim.g.terminal_color_2 = "#84B87E"
vim.g.terminal_color_3 = "#DAC05B"
vim.g.terminal_color_4 = "#97BACC"
vim.g.terminal_color_5 = "#B89CC1"
vim.g.terminal_color_6 = "#63AFA0"
vim.g.terminal_color_7 = "#D4DCC2"
vim.g.terminal_color_8 = "#556753"
vim.g.terminal_color_9 = "#DF867A"
vim.g.terminal_color_10 = "#84B87E"
vim.g.terminal_color_11 = "#DAC05B"
vim.g.terminal_color_12 = "#97BACC"
vim.g.terminal_color_13 = "#B89CC1"
vim.g.terminal_color_14 = "#63AFA0"
vim.g.terminal_color_15 = "#F5F9EA"
