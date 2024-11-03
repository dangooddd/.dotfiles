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
        local function cmp_mapping_pattern(mode)
            return {
                ["<C-n>"] = cmp.mapping({
                    [mode] = cmp.mapping.select_next_item(cmp_select)
                }),
                ["<C-p>"] = cmp.mapping({
                    [mode] = cmp.mapping.select_prev_item(cmp_select)
                }),
                ["<C-e>"] = cmp.mapping({
                    [mode] = cmp.mapping.abort(),
                }),
                ["<C-y>"] = cmp.mapping({
                    [mode] = cmp.mapping.complete(),
                }),
                ["<CR>"] = cmp.mapping({
                    [mode] = function(fallback)
                        if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm(cmp_confirm)
                        else
                            fallback()
                        end
                    end,
                }),
            }
        end

        cmp.setup({
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end
            },
            formatting = {
                -- truncate long lsp items
                format = function(_, item)
                    local content = item.abbr
                    local max_lenght = 30

                    if #content > max_lenght then
                        item.abbr = vim.fn.strcharpart(content, 0, max_lenght) .. ".."
                    end

                    return item
                end,
            },
            mapping = cmp_mapping_pattern("i"),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
            }),
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp_mapping_pattern("c"),
            sources = cmp.config.sources({
                { name = "buffer" },
            }),
        })

        cmp.setup.cmdline(":", {
            mapping = cmp_mapping_pattern("c"),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline" },
            }),
        })
        
        cmp.setup.cmdline("@", {
            mapping = cmp_mapping_pattern("c"),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline" },
            }),
        })
    end,
}
