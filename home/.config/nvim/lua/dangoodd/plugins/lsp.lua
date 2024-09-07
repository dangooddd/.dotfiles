return {
    -- completion system and main lsp setup
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
        lazy = false,
        config = function()
            local cmp = require("cmp")
            -- extend capabilities of nvim in lsp completion
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            require("mason").setup({
                ui = { border = "rounded" },
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
                            handlers = handlers,
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

            -- init completion system
            cmp_select = { behavior = cmp.SelectBehavior.Insert } 
            cmp_confirm = { behavior = cmp.ConfirmBehavior.Replace }
            cmp.setup({
                mapping = {
                    ["<C-n>"] = cmp.mapping({
                        i = cmp.mapping.select_next_item(cmp_select)
                    }),
                    ["<C-p>"] = cmp.mapping({
                        i = cmp.mapping.select_prev_item(cmp_select)
                    }),
                    ["<C-e>"] = cmp.mapping({
                        i = cmp.mapping.abort(),
                    }),
                    ["<C-CR>"] = cmp.mapping({
                        i = cmp.mapping.complete(),
                    }),
                    ["<CR>"] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm(cmp_confirm)
                            else
                                fallback()
                            end
                        end,
                    }),
                },
                formatting = {
                    -- truncate long lsp items
                    format = function(_, item)
                        local content = item.abbr
                        local max_lenght = 25

                        if #content > max_lenght then
                            item.abbr = vim.fn.strcharpart(content, 0, max_lenght) .. ".."
                        end

                        return item
                    end,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                }),
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = {
                    ["<C-n>"] = cmp.mapping({
                        c = cmp.mapping.select_next_item(cmp_select)
                    }),
                    ["<C-p>"] = cmp.mapping({
                        c = cmp.mapping.select_prev_item(cmp_select)
                    }),
                    ["<C-e>"] = cmp.mapping({
                        c = cmp.mapping.abort(),
                    }),
                    ["<C-CR>"] = cmp.mapping({
                        c = cmp.mapping.complete(),
                    }),
                    ["<CR>"] = cmp.mapping({
                        c = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm(cmp_confirm)
                            else
                                fallback()
                            end
                        end,
                    }),
                },
                sources = cmp.config.sources({
                    { name = "buffer" },
                }),
            })

            cmp.setup.cmdline(":", {
                mapping = {
                    ["<C-n>"] = cmp.mapping({
                        c = cmp.mapping.select_next_item(cmp_select)
                    }),
                    ["<C-p>"] = cmp.mapping({
                        c = cmp.mapping.select_prev_item(cmp_select)
                    }),
                    ["<C-e>"] = cmp.mapping({
                        c = cmp.mapping.abort(),
                    }),
                    ["<C-CR>"] = cmp.mapping({
                        c = cmp.mapping.complete(),
                    }),
                    ["<CR>"] = cmp.mapping({
                        c = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm(cmp_confirm)
                            else
                                fallback()
                            end
                        end,
                    }),
                },
                sources = cmp.config.sources({
                    { name = "path" },
                    { name = "cmdline" },
                }),
            })
        end,
    },
    -- formatter
    {
        "stevearc/conform.nvim",
        config = function()
            require("conform").setup({
                format_on_save = {
                    timeout_ms = 500,
                    lsp_format = "fallback",
                }
            })
        end,
    },
}