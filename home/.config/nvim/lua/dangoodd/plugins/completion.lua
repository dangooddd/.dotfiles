return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = { "L3MON4D3/LuaSnip" },
    config = function()
        require("blink.cmp").setup({
            snippets = {
                expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
                active = function(filter)
                    if filter and filter.direction then
                        return require("luasnip").jumpable(filter.direction)
                    end
                    return require("luasnip").in_snippet()
                end,
                jump = function(direction) require("luasnip").jump(direction) end,
            },
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
            completion = {
                list = {
                    selection = "manual",
                    cycle = {
                        from_bottom = false,
                        from_top = false,
                    },
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 50,
                },
                menu = {
                    draw = {
                        columns = { 
                            { "label", "label_description", gap = 1 }, 
                            { "kind_icon", "kind", gap = 1 },
                        },
                    },
                },
            },
            sources = {
                default = { "lsp", "path", "luasnip", "buffer" },
                cmdline = function()
                    local type = vim.fn.getcmdtype()
                    if type == "/" or type == "?" then return { "buffer" } end
                    if type == ":" then return { "cmdline" } end
                    return {}
                end,
            },
        })
    end
}
