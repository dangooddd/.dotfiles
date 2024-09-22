return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        -- luasnip as snippet engine
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")

        -- init completion system
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        local cmp_confirm = { behavior = cmp.ConfirmBehavior.Replace }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end
            },
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
                    local max_lenght = 40

                    if #content > max_lenght then
                        item.abbr = vim.fn.strcharpart(content, 0, max_lenght) .. ".."
                    end

                    return item
                end,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
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
}
