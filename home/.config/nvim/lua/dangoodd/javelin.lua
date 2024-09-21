---------------------------------------
-- Javelin functions
---------------------------------------
local javelin_keys = { "q", "w", "e", "r" }
local javelins = {}
-- initialize javelins
for _, key in ipairs(javelin_keys) do
    javelins[key] = "-"
end

local function javelin_throw(key)
    return function()
        local message = string.format("javelin: throw [%s]", key)
        javelins[key] = vim.fn.histget("", -1)
        vim.notify(message, vim.log.levels.INFO)
    end
end

local function javelin_pull(key)
    return function()
        if (javelins[key] ~= "-") then
            -- returns expression
            return string.format(":%s", javelins[key])
        end
    end
end

local function javelin_show()
    local out_table = { "-- JAVELIN --" }
    for _, key in ipairs(javelin_keys) do
        local javelin = javelins[key]
        local line = string.format("%s = %s", key, javelin)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

---------------------------------------
-- Keybinds
---------------------------------------
for _, key in ipairs(javelin_keys) do
    vim.keymap.set("n", "<leader>j"..key, javelin_pull(key), { expr = true })
    vim.keymap.set("n", "<leader>jk"..key, javelin_throw(key))
end
vim.keymap.set("n", "<leader>jj", javelin_show)
