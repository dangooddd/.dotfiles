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
                -- completion menu
                local CPmenu = { fg = theme.ui.shade0, bg = theme.ui.bg }
                local CPmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 }
                local CPmenuSbar = { bg = theme.ui.bg_m1 }
                local CPmenuThumb = { bg = palette.waveAqua2 }
                return {
                    -- other
                    CursorLineNr = { bold = false },
                    ModeMsg = { bold = false },
                    WinSeparator = { fg = theme.ui.bg_p1 },
                    ["@variable.builtin"] = { italic = false },
                    -- menu
                    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                    -- blink menu
                    BlinkCmpMenu = CPmenu,
                    BlinkCmpMenuBorder = CPmenu,
                    BlinkCmpMenuSelection = CPmenuSel,
                    BlinkCmpScrollBarThumb = CPmenuThumb,
                    BlinkCmpScrollBarGutter = CPmenuSbar,
                    BlinkCmpDoc = CPmenu,
                    BlinkCmpDocBorder = CPmenu,
                    BlinkCmpDocSeparator = CPmenu,
                    BlinkCmpSignatureHelp = CPmenu,
                    BlinkCmpSignatureHelpBorder = CPmenu,
                }
            end
        })
        vim.cmd("colorscheme kanagawa")
    end,
}
