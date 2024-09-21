---------------------------------------
-- Hook functions
---------------------------------------
local hook_keys = { "q", "w", "e", "r" }
local hooks = {}
-- initialize hooks
for _, key in ipairs(hook_keys) do
    hooks[key] = "-"
end

local function hook_throw(key, file)
    return function()
        hooks[key] = file 
    end
end

local function hook_pull(key)
    return function()
        if (vim.fn.filereadable(hooks[key]) == 1) then
            vim.cmd.edit(hooks[key])
        end
    end
end

local function hook_show()
    local out_table = { "-- HOOK --" }
    for _, key in ipairs(hook_keys) do
        local path = string.gsub(hooks[key], vim.env.HOME, "~", 1)
        local line = string.format("%s = %s", key, path)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

---------------------------------------
-- Keybinds
---------------------------------------
for _, key in ipairs(hook_keys) do
    vim.keymap.set("n", "<leader>h"..key, hook_pull(key))
end
vim.keymap.set("n", "<leader>hh", hook_show)

-- save only on buflisted buffers
vim.api.nvim_create_augroup("Hook", {})
vim.api.nvim_create_autocmd("BufEnter", {
    group = "Hook",
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local file = args.file
        if (vim.bo.buflisted) then
            for _, key in ipairs(hook_keys) do
                vim.keymap.set("n", "<leader>hl"..key, hook_throw(key, file), { buffer = buf })
            end
        end
    end,
})
