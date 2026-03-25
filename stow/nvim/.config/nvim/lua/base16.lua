local M = {}

---@class base16.Palette
---@field base00 string
---@field base01 string
---@field base02 string
---@field base03 string
---@field base04 string
---@field base05 string
---@field base06 string
---@field base07 string
---@field base08 string
---@field base09 string
---@field base0A string
---@field base0B string
---@field base0C string
---@field base0D string
---@field base0E string
---@field base0F string

---@param p base16.Palette
M.setup = function(p)
    if vim.g.colors_name then
        vim.cmd("highlight clear")
    end

    vim.g.colors_name = nil

    local function hl(name, val)
        vim.api.nvim_set_hl(0, name, val)
    end

    -- completion
    hl("ComplMatchIns", {})
    hl("Pmenu", { fg = p.base05, bg = p.base01 })
    hl("PmenuExtra", { link = "Pmenu" })
    hl("PmenuMatch", { fg = p.base05, bold = true })
    hl("PmenuKind", { link = "Pmenu" })
    hl("PmenuSel", { bg = p.base03 })
    hl("PmenuExtraSel", { link = "PmenuSel" })
    hl("PmenuMatchSel", { fg = p.base05, bold = true })
    hl("PmenuKindSel", { link = "PmenuSel" })
    hl("PmenuSbar", { bg = p.base02 })
    hl("PmenuThumb", { bg = p.base04 })

    -- cursor search
    hl("CurSearch", { fg = p.base01, bg = p.base09 })
    hl("Cursor", { fg = p.base00, bg = p.base05 })
    hl("CursorColumn", { bg = p.base01 })
    hl("CursorIM", { fg = p.base00, bg = p.base05 })
    hl("CursorLine", { bg = p.base01 })
    hl("CursorLineFold", { fg = p.base0C, bg = p.base01 })
    hl("CursorLineNr", { fg = p.base04, bg = p.base01 })
    hl("CursorLineSign", { fg = p.base03, bg = p.base01 })
    hl("IncSearch", { fg = p.base01, bg = p.base09 })
    hl("Search", { fg = p.base01, bg = p.base0A })
    hl("lCursor", { fg = p.base00, bg = p.base05 })
    hl("MatchParen", { bg = p.base02 })

    -- diff
    hl("DiffAdd", { fg = p.base0B, bg = p.base01 })
    hl("DiffChange", { fg = p.base0E, bg = p.base01 })
    hl("DiffDelete", { fg = p.base08, bg = p.base01 })
    hl("DiffText", { fg = p.base0D, bg = p.base01 })

    -- spell
    hl("SpellBad", { undercurl = true, sp = p.base08 })
    hl("SpellCap", { undercurl = true, sp = p.base0D })
    hl("SpellLocal", { undercurl = true, sp = p.base0C })
    hl("SpellRare", { undercurl = true, sp = p.base0E })

    -- status tabs
    hl("StatusLine", { fg = p.base04, bg = p.base02 })
    hl("StatusLineNC", { fg = p.base03, bg = p.base01 })
    hl("TabLine", { fg = p.base03, bg = p.base01 })
    hl("TabLineFill", { fg = p.base03, bg = p.base01 })
    hl("TabLineSel", { fg = p.base0B, bg = p.base01 })
    hl("WinBar", { fg = p.base04, bg = p.base02 })
    hl("WinBarNC", { fg = p.base03, bg = p.base01 })
    hl("WinSeparator", { fg = p.base02, bg = p.base02 })

    -- editor ui
    hl("ColorColumn", { bg = p.base01 })
    hl("Conceal", { fg = p.base0D })
    hl("Directory", { fg = p.base0D })
    hl("EndOfBuffer", { fg = p.base03 })
    hl("ErrorMsg", { fg = p.base08 })
    hl("FloatBorder", { link = "NormalFloat" })
    hl("FoldColumn", { fg = p.base0C, bg = p.base01 })
    hl("Folded", { fg = p.base03, bg = p.base01 })
    hl("LineNr", { fg = p.base03, bg = p.base01 })
    hl("LineNrAbove", { fg = p.base03, bg = p.base01 })
    hl("LineNrBelow", { fg = p.base03, bg = p.base01 })
    hl("ModeMsg", { fg = p.base0B })
    hl("MoreMsg", { fg = p.base0B })
    hl("MsgArea", { link = "Normal" })
    hl("MsgSeparator", { fg = p.base02, bg = p.base02 })
    hl("NonText", { fg = p.base03 })
    hl("Normal", { fg = p.base05, bg = p.base00 })
    hl("NormalFloat", { fg = p.base05, bg = p.base01 })
    hl("NormalNC", { fg = p.base05, bg = p.base00 })
    hl("OkMsg", { fg = p.base0B })
    hl("Question", { fg = p.base0D })
    hl("QuickFixLine", { bg = p.base01 })
    hl("SignColumn", { fg = p.base03, bg = p.base01 })
    hl("SpecialKey", { fg = p.base03 })
    hl("StderrMsg", { link = "ErrorMsg" })
    hl("StdoutMsg", { link = "MsgArea" })
    hl("Substitute", { fg = p.base01, bg = p.base0A })
    hl("TermCursor", { reverse = true })
    hl("TermCursorNC", { reverse = true })
    hl("Title", { fg = p.base0D })
    hl("FloatTitle", { fg = p.base0D, bg = p.base01 })
    hl("VertSplit", { fg = p.base02, bg = p.base02 })
    hl("Visual", { bg = p.base02 })
    hl("VisualNOS", { fg = p.base08 })
    hl("WarningMsg", { fg = p.base09 })
    hl("Whitespace", { fg = p.base03 })
    hl("WildMenu", { fg = p.base08, bg = p.base0A })

    -- syntax
    hl("Boolean", { fg = p.base0A })
    hl("Character", { fg = p.base08 })
    hl("Comment", { fg = p.base03 })
    hl("Conditional", { fg = p.base0E })
    hl("Constant", { fg = p.base0A })
    hl("Debug", { fg = p.base08 })
    hl("Define", { fg = p.base0E })
    hl("Delimiter", { fg = p.base0F })
    hl("Error", { fg = p.base00, bg = p.base08 })
    hl("Exception", { fg = p.base08 })
    hl("Float", { fg = p.base09 })
    hl("Function", { fg = p.base0D })
    hl("Identifier", { fg = p.base0C })
    hl("Ignore", { fg = p.base0C })
    hl("Include", { fg = p.base08 })
    hl("Keyword", { fg = p.base0E })
    hl("Label", { fg = p.base0A })
    hl("Macro", { fg = p.base08 })
    hl("Number", { fg = p.base09 })
    hl("Operator", { fg = p.base05 })
    hl("PreCondit", { fg = p.base08 })
    hl("PreProc", { fg = p.base08 })
    hl("Repeat", { fg = p.base0A })
    hl("Special", { fg = p.base09 })
    hl("SpecialChar", { fg = p.base0F })
    hl("SpecialComment", { fg = p.base0C })
    hl("Statement", { fg = p.base08 })
    hl("StorageClass", { fg = p.base0A })
    hl("String", { fg = p.base0B })
    hl("Structure", { fg = p.base0E })
    hl("Underlined", { underline = true })
    hl("Tag", { fg = p.base0A })
    hl("Todo", { fg = p.base0A, bg = p.base01 })
    hl("Type", { fg = p.base0A })
    hl("Typedef", { fg = p.base0A })

    -- patch diff
    hl("diffAdded", { fg = p.base0B })
    hl("diffChanged", { fg = p.base0E })
    hl("diffFile", { fg = p.base09 })
    hl("diffLine", { fg = p.base0C })
    hl("diffRemoved", { fg = p.base08 })
    hl("Added", { fg = p.base0B })
    hl("Changed", { fg = p.base0E })
    hl("Removed", { fg = p.base08 })

    -- git commit
    hl("gitcommitBranch", { fg = p.base09, bold = true })
    hl("gitcommitComment", { link = "Comment" })
    hl("gitcommitDiscarded", { link = "Comment" })
    hl("gitcommitDiscardedFile", { fg = p.base08, bold = true })
    hl("gitcommitDiscardedType", { fg = p.base0D })
    hl("gitcommitHeader", { fg = p.base0E })
    hl("gitcommitOverflow", { fg = p.base08 })
    hl("gitcommitSelected", { link = "Comment" })
    hl("gitcommitSelectedFile", { fg = p.base0B, bold = true })
    hl("gitcommitSelectedType", { link = "gitcommitDiscardedType" })
    hl("gitcommitSummary", { fg = p.base0B })
    hl("gitcommitUnmergedFile", { link = "gitcommitDiscardedFile" })
    hl("gitcommitUnmergedType", { link = "gitcommitDiscardedType" })
    hl("gitcommitUntracked", { link = "Comment" })
    hl("gitcommitUntrackedFile", { fg = p.base0A })

    -- diagnostics
    hl("DiagnosticError", { fg = p.base08 })
    hl("DiagnosticHint", { fg = p.base0C })
    hl("DiagnosticInfo", { fg = p.base0D })
    hl("DiagnosticOk", { fg = p.base0B })
    hl("DiagnosticWarn", { fg = p.base0A })
    hl("DiagnosticFloatingError", { fg = p.base08, bg = p.base01 })
    hl("DiagnosticFloatingHint", { fg = p.base0C, bg = p.base01 })
    hl("DiagnosticFloatingInfo", { fg = p.base0D, bg = p.base01 })
    hl("DiagnosticFloatingOk", { fg = p.base0B, bg = p.base01 })
    hl("DiagnosticFloatingWarn", { fg = p.base0A, bg = p.base01 })
    hl("DiagnosticSignError", { link = "DiagnosticFloatingError" })
    hl("DiagnosticSignHint", { link = "DiagnosticFloatingHint" })
    hl("DiagnosticSignInfo", { link = "DiagnosticFloatingInfo" })
    hl("DiagnosticSignOk", { link = "DiagnosticFloatingOk" })
    hl("DiagnosticSignWarn", { link = "DiagnosticFloatingWarn" })
    hl("DiagnosticUnderlineError", { undercurl = true, sp = p.base08 })
    hl("DiagnosticUnderlineHint", { undercurl = true, sp = p.base0C })
    hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.base0D })
    hl("DiagnosticUnderlineOk", { undercurl = true, sp = p.base0B })
    hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.base0A })

    -- snippets
    hl("SnippetTabstop", { link = "Visual" })
    hl("SnippetTabstopActive", { link = "SnippetTabstop" })

    -- headings
    hl("markdownH1", { fg = p.base09 })
    hl("markdownH2", { fg = p.base0A })
    hl("markdownH3", { fg = p.base0B })
    hl("markdownH4", { fg = p.base0C })
    hl("markdownH5", { fg = p.base0D })
    hl("markdownH6", { fg = p.base0F })

    -- treesitter
    hl("@keyword.return", { fg = p.base08 })
    hl("@keyword.import", { link = "Include" })
    hl("@symbol", { fg = p.base0E })
    hl("@variable", { fg = p.base05 })
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
    hl("@variable.parameter.vimdoc", { fg = p.base09 })
    hl("@markup.heading.4.vimdoc", { link = "Title" })

    -- lsp
    hl("LspReferenceText", { bg = p.base02 })
    hl("LspReferenceRead", { link = "LspReferenceText" })
    hl("LspReferenceWrite", { link = "LspReferenceText" })
    hl("LspSignatureActiveParameter", { link = "LspReferenceText" })
    hl("LspCodeLens", { link = "Comment" })
    hl("LspCodeLensSeparator", { link = "Comment" })
    hl("@lsp.type.variable", { fg = p.base05 })
    hl("@lsp.mod.deprecated", { fg = p.base08 })

    -- terminal colors
    vim.g.terminal_color_0 = p.base00
    vim.g.terminal_color_1 = p.base08
    vim.g.terminal_color_2 = p.base0B
    vim.g.terminal_color_3 = p.base0A
    vim.g.terminal_color_4 = p.base0D
    vim.g.terminal_color_5 = p.base0E
    vim.g.terminal_color_6 = p.base0C
    vim.g.terminal_color_7 = p.base05
    vim.g.terminal_color_8 = p.base03
    vim.g.terminal_color_9 = p.base08
    vim.g.terminal_color_10 = p.base0B
    vim.g.terminal_color_11 = p.base0A
    vim.g.terminal_color_12 = p.base0D
    vim.g.terminal_color_13 = p.base0E
    vim.g.terminal_color_14 = p.base0C
    vim.g.terminal_color_15 = p.base07
end

return M
