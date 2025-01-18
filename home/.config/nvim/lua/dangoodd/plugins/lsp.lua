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
        -- TODO: add on_attach function for inlay hints
        -- https://github.com/gennaro-tedesco/dotfiles/blob/7385fa7f2d28b9b3ac5f18f52894127e433ab81c/nvim/lua/plugins/lsp.lua#L46-L59

        -- mason
        require("mason").setup({ ui = { border = "rounded" } })
        
        -- setup lsp
        require("mason-lspconfig").setup({
            ensure_installed = {
                "pylsp",
                "clangd",
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
