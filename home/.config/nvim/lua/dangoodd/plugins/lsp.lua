return {
    -- completion system and main lsp setup
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        -- extend capabilities of nvim in lsp completion
        local capabilities = vim.tbl_deep_extend(
            "force",
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities()
        )

        require("mason").setup({
            ui = { border = "single" },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "pylsp",
            },
            -- functions to call on start of lsp
            -- basically auto setup of lsp
            handlers = {
                -- default handler
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                    })
                end,

                ["pylsp"] = function()
                    require("lspconfig")["pylsp"].setup({
                        capabilities = capabilities,
                        settings = {
                            pylsp = {
                                plugins = {
                                    yapf = { enabled = true },
                                    autopep8 = { enabled = false },
                                }
                            },
                        },
                    })
                end,
            },
        })
    end,
}
