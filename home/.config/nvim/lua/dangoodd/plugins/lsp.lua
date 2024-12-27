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
        local border = "single"

        -- set borders
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, { border = border }
        )

        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help, { border = border }
        )

        vim.diagnostic.config({ float={ border = border } })
        require("mason").setup({ ui = { border = border } })

        -- setup lsp
        require("mason-lspconfig").setup({
            ensure_installed = {
                "pylsp",
                "clangd",
                "bashls",
                "taplo",
                "jsonls",
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
