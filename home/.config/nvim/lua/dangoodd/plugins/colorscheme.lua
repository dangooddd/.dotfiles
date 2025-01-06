return {
    "rebelot/kanagawa.nvim",
    priority = 1000,  -- load first
    config = function()
        require("kanagawa").setup({
            commentStyle = { italic = false },
            keywordStyle = { italic = false },
            undercurl = true,
            background = {
                dark = "wave",
                light = "lotus"
            },
            colors = {
                theme = {
                    all = {
                        ui = { bg_gutter = "NONE" },
                    },
                    wave = {
                        term = (function()
                            local wave = require("kanagawa.colors").setup({ theme = "wave" })
                            wave.theme.term[10] = wave.palette.peachRed
                            return wave.theme.term
                        end)(),
                    },
                },
            },
            overrides = function(colors)
                local theme = colors.theme
                return {
                    -- other
                    CursorLineNr = { bold = false },
                    ModeMsg = { bold = false },
                    WinSeparator = { fg = theme.ui.bg_p1 },
                    ["@variable.builtin"] = { italic = false },
                    -- menu
                    Pmenu = { fg = theme.ui.fg , bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                    -- blink menu
                    BlinkCmpMenu = { fg = theme.ui.fg, bg = theme.ui.bg },
                    BlinkCmpLabelMatch = { fg = theme.ui.special },
                    BlinkCmpMenuBorder = { link = "BlinkCmpMenu" },
                    BlinkCmpMenuSelection = { fg = "NONE", bg = theme.ui.bg_p2 },
                    BlinkCmpScrollBarGutter = { bg = theme.ui.bg_p1 },
                    BlinkCmpScrollBarThumb = { bg = theme.ui.fg },
                    BlinkCmpDoc = { link = "BlinkCmpMenu" },
                    BlinkCmpDocBorder = { link = "BlinkCmpMenu" },
                    BlinkCmpDocSeparator = { link = "BlinkCmpMenu" },
                    BlinkCmpSignatureHelp = { link = "BlinkCmpMenu" },
                    BlinkCmpSignatureHelpBorder = { link = "BlinkCmpMenu" },
                }
            end
        })
        vim.cmd.colorscheme("kanagawa")
    end,
}
