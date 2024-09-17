---------------------------------------
-- Keybinds
---------------------------------------
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", {})
vim.keymap.set("n", "<leader>bp", ":bprev<CR>", {})

local function map_snippet_jump(direction, keymap)
    local function snippet_jump()
        if vim.snippet.active({ direction = direction }) then
            return string.format("<cmd>lua vim.snippet.jump(%i)<CR>", direction)
        else
            return keymap
        end
    end
    vim.keymap.set({ "i", "s" }, keymap, snippet_jump, { expr = true })
end

map_snippet_jump(1, "<Tab>")
map_snippet_jump(-1, "<S-Tab>")
