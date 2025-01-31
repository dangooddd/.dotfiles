return {
    -- completion system and main lsp setup
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "saghen/blink.cmp",
    },
    config = function()
        -- extend capabilities of nvim in lsp completion
        local capabilities = require("blink.cmp").get_lsp_capabilities()

        -- mason
        require("mason").setup({ ui = { border = "rounded" } })

        -- setup lsp
        require("mason-lspconfig").setup({
            ensure_installed = {
                "basedpyright",
                "clangd",
                "lua_ls",
                "bashls",
                "taplo",
                "jsonls",
                "yamlls",
                "texlab",
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

                ["lua_ls"] = function()
                    require("lspconfig")["lua_ls"].setup({
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    disable = {
                                        "missing-fields",
                                        "undefined-global",
                                    },
                                },
                            },
                        },
                    })
                end,

                ["basedpyright"] = function()
                    require("lspconfig")["basedpyright"].setup({
                        capabilities = capabilities,
                        settings = {
                            basedpyright = {
                                analysis = {
                                    typeCheckingMode = "standard",
                                },
                            },
                        },
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
                                        ignore = { "E203", "E701", "W503" },
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
                                    "--exclude=SC1090,SC1091,SC2076,SC2164"
                                },
                            }
                        }
                    })
                end,

                ["clangd"] = function()
                    require("lspconfig")["clangd"].setup({
                        capabilities = capabilities,
                        cmd = {
                            "clangd",
                            "--fallback-style=llvm",
                            "--header-insertion=iwyu",
                            "-j=4",
                        },
                    })
                end,
            },
        })
    end,
}
