return {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("kanagawa").setup({
            commentStyle = { italic = false },
            keywordStyle = { italic = false },  
            colors = {
                theme = {
                    all = { 
                        ui  = { bg_gutter = 'none' },
                    }, 
                },
            },
            overrides = function(colors)
                local theme = colors.theme
                return {
                    CursorLineNr = { bold = false },
                    -- menu
                    Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
                    PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                    PmenuSbar = { bg = theme.ui.bg_m1 },
                    PmenuThumb = { bg = theme.ui.bg_p2 },
                    -- float windows
                    NormalFloat = { bg = "none" },
                    FloatBorder = { bg = "none" },
                    FloatTitle = { bg = "none" },
                }
            end
        })
        vim.cmd("colorscheme kanagawa")
    end,
}
