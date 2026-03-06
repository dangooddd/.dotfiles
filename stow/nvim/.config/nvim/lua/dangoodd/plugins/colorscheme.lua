return {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
        require("rose-pine").setup({
            styles = {
                italic = false,
                transparency = true,
            },
            highlight_groups = {
                Pmenu = { bg = "overlay" },
                PmenuSel = { bg = "highlight_med" },
                PmenuKindSel = { bg = "highlight_med", fg = "rose" },
                PmenuSbar = { bg = "highlight_med" },
            },
        })
        vim.cmd("colorscheme rose-pine")
    end,
}
