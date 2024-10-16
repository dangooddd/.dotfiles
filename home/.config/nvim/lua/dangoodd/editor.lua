---------------------------------------
-- Hook
---------------------------------------
local Hook = {}
Hook.map = {}

function Hook.edit_command()
    local count = vim.v.count1
    local message = string.format("Command (%s): ", count) 
    local default = Hook.map[count] or ""
    function command_callback(command)
        if command ~= nil then
            Hook.map[count] = command
        end
    end
    vim.ui.input({ prompt = message, completion = "command", default = default }, command_callback)
end

function Hook.run_command()
    local count = vim.v.count1
    return string.format(":<C-U>%s", Hook.map[count] or "")
end

vim.keymap.set("n", "<leader>j", Hook.edit_command)
vim.keymap.set("n", "<leader>h", Hook.run_command, { expr = true })


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
