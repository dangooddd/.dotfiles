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
                }
            end
        })
        vim.cmd("colorscheme kanagawa")
    end,
}
