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
                ["<Tab>"] = { "snippet_forward", "snippet_backward" },
            },
            completion = {
                list = {
                    selection = "manual",
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 100,
                },
            },
            sources = {
                default = { "lsp", "path", "luasnip", "buffer" },
            },
        })
    end
}
