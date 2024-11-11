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
                "clangd",
                "bashls",
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
                                    -- use black as default formatter
                                    yapf = { enabled = false },
                                    autopep8 = { enabled = false },
                                    black = { enabled = true },
                                    pycodestyle = {
                                        enabled = true,
                                        ignore = { "E203", "E701" },
                                        maxLineLength = 88
                                    }
                                }
                            },
                        },
                    })
                end,

                ["texlab"] = function()
                    require("lspconfig")["texlab"].setup({
                        capabilities = capabilities,
                        settings = {
                            texlab = {
                                build = {
                                    executable = "latexmk",
                                    args = {
                                        "-lualatex",
                                        "-interaction=nonstopmode",
                                        "-outdir=build",
                                    },
                                    onSave = true,
                                },
                            }
                        }
                    })
                end,

                ["bashls"] = function()
                    require("lspconfig")["bashls"].setup({
                        capabilities = capabilities,
                        settings = {
                            bashIde = {
                                shellcheckArguments = {
                                    "--exclude=SC1090,SC1091,SC2076"
                                },
                            }
                        }
                    })
                end,

                ["clangd"] = function()
                    local style = "llvm"
                    require("lspconfig")["clangd"].setup({
                        capabilities = capabilities,
                        cmd = {
                            "clangd",
                            "--fallback-style="..style,
                        }
                    })
                end,
            },
        })
    end,
}
