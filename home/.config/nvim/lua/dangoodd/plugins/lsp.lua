return {
    -- default lsp configs
    {
        "neovim/nvim-lspconfig",
        config = function() end,
    },

    -- lsp installer
    {
        "williamboman/mason.nvim",
        config = function()
            -- mason
            require("mason").setup({
                ui = {
                    border = "rounded",
                    backdrop = 100,
                },
            })
        end,
    },
}
