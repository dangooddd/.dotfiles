---------------------------------------
-- Javelin and Hook
---------------------------------------
local quick_keys = { "q", "w", "e", "r" }
local Javelin = {}
Javelin.list = {}
local Hook = {}
Hook.list = {}

-- initialize
for _, key in ipairs(quick_keys) do
    Hook.list[key] = "-"
    Javelin.list[key] = "-"
end

-- Javelin methods
function Javelin.throw(key)
    return function()
        local message = string.format("javelin: throw [%s]", key)
        local count = vim.v.count1 * (-1)
        Javelin.list[key] = vim.fn.histget("", count)
        vim.notify(message, vim.log.levels.INFO)
    end
end

function Javelin.pull(key)
    return function()
        if (Javelin.list[key] ~= "-") then
            -- returns expression
            return string.format(":%s", Javelin.list[key])
        end
    end
end

function Javelin.show()
    local out_table = { "-- JAVELIN --" }
    for _, key in ipairs(quick_keys) do
        local javelin = Javelin.list[key]
        local line = string.format("%s = %s", key, javelin)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

-- Hook methods
function Hook.throw(key)
    return function()
        local file = vim.api.nvim_buf_get_name(0)
        local message = string.format("hook: throw [%s]", key)
        if (vim.bo.buflisted) then
            Hook.list[key] = file 
            vim.notify(message, vim.log.levels.INFO)
        end
    end
end

function Hook.pull(key)
    return function()
        if (vim.fn.filereadable(Hook.list[key]) == 1) then
            vim.cmd.edit(Hook.list[key])
        end
    end
end

function Hook.show()
    local out_table = { "-- HOOK --" }
    for _, key in ipairs(quick_keys) do
        local path = string.gsub(Hook.list[key], vim.env.HOME, "~", 1)
        local line = string.format("%s = %s", key, path)
        table.insert(out_table, line)
    end
    vim.api.nvim_echo({ { table.concat(out_table, "\n") } }, true, {})
end

-- keybinds
for _, key in ipairs(quick_keys) do
    -- Javelin
    vim.keymap.set("n", "<leader>j"..key, Javelin.pull(key), { expr = true })
    vim.keymap.set("n", "<leader>jk"..key, Javelin.throw(key))
    -- Hook
    vim.keymap.set("n", "<leader>h"..key, Hook.pull(key))
    vim.keymap.set("n", "<leader>hl"..key, Hook.throw(key))
end
vim.keymap.set("n", "<leader>jj", Javelin.show)
vim.keymap.set("n", "<leader>hh", Hook.show)


---------------------------------------
-- Centering
---------------------------------------
local Centering = {}

function Centering.toggle()
    local goff = vim.api.nvim_get_option_value("scrolloff", { scope = "global" }) 
    local loff = vim.api.nvim_get_option_value("scrolloff", { scope = "local" }) 
    if loff ~= 999 then
        vim.opt_local.scrolloff = 999
    else
        vim.opt_local.scrolloff = goff
    end
end

-- keybinds
vim.keymap.set("n", "<leader>c", Centering.toggle)


---------------------------------------
-- Background
---------------------------------------
local Background = {}

function Background.toggle()
    local background = vim.api.nvim_get_option_value("background", { scope = "global" })
    if background== "dark" then
        vim.opt.background = "light"
    else
        vim.opt.background = "dark"
    end
end

-- keybinds
vim.keymap.set("n", "<leader>l", Background.toggle)
