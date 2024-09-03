return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
    },
    lazy = false,
    config = function()
        require("mason").setup()
        require("mason").setup({
            ensure_installed = {
                "pylsp",
            }
        })
        local cmp = require("cmp")
        cmp.setup({})
    end,
}
