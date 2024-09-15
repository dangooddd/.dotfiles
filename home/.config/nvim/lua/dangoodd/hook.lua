local hooks = {}
local keys = {"q", "w", "e", "r"}

local function save(key)
    return function()
        hooks[key] = vim.api.nvim_buf_get_name(0) 
    end
end

local function load(key)
    return function()
        if (vim.fn.filereadable(hooks[key])) then
            vim.cmd.edit(hooks[key])
        end
    end
end

for _, key in ipairs(keys) do
    vim.keymap.set("n", "<leader>f"..key, load(key))
end

vim.api.nvim_create_augroup("Hook", {})
vim.api.nvim_create_autocmd("BufEnter", {
    group = "Hook",
    pattern = "*",
    callback = function()
        if (vim.bo.buflisted) then
            for _, key in ipairs(keys) do
                vim.keymap.set("n", "<leader>"..key..key, save(key))
            end
        end
    end,
})
