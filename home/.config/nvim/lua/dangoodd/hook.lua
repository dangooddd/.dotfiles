---------------------------------------
-- Hook functions
---------------------------------------
local hooks = {
    ["q"] = -1,
    ["w"] = -1,
    ["e"] = -1,
    ["r"] = -1,
}

local function save_hook(key, file)
    return function()
        hooks[key] = file 
    end
end

local function edit_hook(key)
    return function()
        if (vim.fn.filereadable(hooks[key]) == 1) then
            vim.cmd.edit(hooks[key])
        end
    end
end

local function list_hooks()
    local out_table = {}
    for key, value in pairs(hooks) do
        local path = string.gsub(value, vim.env.HOME, "~")
        local line = string.format("%s = %s", key, path)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

---------------------------------------
-- Keybinds
---------------------------------------
for key, _ in pairs(hooks) do
    vim.keymap.set("n", "<leader>"..key, edit_hook(key))
end
vim.keymap.set("n", "<leader>hh", list_hooks)

-- save only on buflisted buffers
vim.api.nvim_create_augroup("Hook", {})
vim.api.nvim_create_autocmd("BufEnter", {
    group = "Hook",
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local file = args.file
        if (vim.bo.buflisted) then
            for key, _ in pairs(hooks) do
                vim.keymap.set("n", "<leader>h"..key, save_hook(key, file), { buffer = buf })
            end
        end
    end,
})
