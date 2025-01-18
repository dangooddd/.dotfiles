return {
    -- snippets
    {
        "L3MON4D3/LuaSnip",
        version = "*",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    -- completion
    {
        "saghen/blink.cmp",
        version = "*",
        dependencies = { "L3MON4D3/LuaSnip" },
        config = function()
            require("blink.cmp").setup({
                completion = {
                    list = {
                        selection = {
                            preselect = false,
                            auto_insert = false,
                        },
                        cycle = {
                            from_bottom = false,
                            from_top = false,
                        },
                    },
                    documentation = {
                        window = { border = "rounded" },
                        auto_show = true,
                        auto_show_delay_ms = 50,
                    },
                    menu = {
                        border = "rounded",
                        draw = {
                            columns = { 
                                { "label" }, 
                                { "kind_icon", "kind", gap = 1 },
                            },
                        },
                    },
                },
                signature = { 
                    enabled = true,
                    window = { border = "rounded" },
                },
                sources = {
                    default = { "lsp", "path", "snippets", "buffer" },
                },
                snippets = { preset = "luasnip" },
                keymap = {
                    ["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
                    ["<C-e>"] = { "hide" },
                    ["<C-p>"] = { "select_prev", "fallback" },
                    ["<C-n>"] = { "select_next", "fallback" },
                    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                    ["<CR>"] = { "accept", "fallback" },
                    ["<Tab>"] = { "snippet_forward", "fallback" },
                    ["<S-Tab>"] = { "snippet_backward", "fallback" }
                },
            })
        end,
    },
}
