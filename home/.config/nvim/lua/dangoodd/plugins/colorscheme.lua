return {
    "rebelot/kanagawa.nvim",
    priority = 1000,  -- load first
    config = function()
        require("kanagawa").setup({
            commentStyle = { italic = false },
            keywordStyle = { italic = false },
            undercurl = true,
            colors = {
                theme = {
                    all = {
                        ui = { bg_gutter = "NONE" },
                    },
                },
            },
            overrides = function(colors)
                local theme = colors.theme
                local palette = colors.palette
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
                    BlinkCmpMenuBorder = { link = "BlinkCmpMenu" },
                    BlinkCmpMenuSelection = { fg = theme.ui.bg, bg = palette.springGreen },
                    BlinkCmpScrollBarGutter = { bg = theme.ui.bg_p2 },
                    BlinkCmpScrollBarThumb = { bg = palette.surimiOrange },
                    BlinkCmpDoc = { link = "BlinkCmpMenu" },
                    BlinkCmpDocBorder = { link = "BlinkCmpMenu" },
                    BlinkCmpDocSeparator = { link = "BlinkCmpMenu" },
                    BlinkCmpSignatureHelp = { link = "BlinkCmpMenu" },
                    BlinkCmpSignatureHelpBorder = { link = "BlinkCmpMenu" },
                }
            end
        })
        vim.cmd("colorscheme kanagawa")
    end,
}
