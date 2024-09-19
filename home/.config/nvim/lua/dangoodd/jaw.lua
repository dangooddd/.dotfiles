---------------------------------------
-- Jaw functions
---------------------------------------
local jaw_keys = { "q", "w", "e", "r" }
local jaws = {}
-- initialize jaws
for _, key in ipairs(jaw_keys) do
    jaws[key] = "-"
end

local function jaw_hold(key)
    return function()
        jaws[key] = vim.fn.histget("", -1)
    end
end

local function jaw_bite(key)
    return function()
        if (jaws[key] ~= "-") then
            -- returns expression
            return string.format(":%s", jaws[key])
        end
    end
end

local function jaw_show()
    local out_table = {}
    for _, key in ipairs(jaw_keys) do
        local jaw = jaws[key]
        local line = string.format("%s = %s", key, jaw)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

---------------------------------------
-- Keybinds
---------------------------------------
for _, key in ipairs(jaw_keys) do
    vim.keymap.set("n", "<leader>j"..key, jaw_bite(key), { expr = true })
    vim.keymap.set("n", "<leader>jk"..key, jaw_hold(key))
end
vim.keymap.set("n", "<leader>jj", jaw_show)
