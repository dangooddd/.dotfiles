return {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        local ls = require("luasnip")
        local function map_ls_jump(direction, key)
            local function ls_jump()
                if ls.expand_or_jumpable() then
                    return string.format("<cmd>lua require'luasnip'.jump(%i)<CR>", direction)
                else
                    return key
                end
            end
            vim.keymap.set({ "i", "s" }, key, ls_jump, { expr = true, silent = true })
        end

        map_ls_jump(1, "<Tab>")
        map_ls_jump(-1, "<S-Tab>")
    end
}
