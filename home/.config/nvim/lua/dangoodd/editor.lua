---------------------------------------
-- Javelin and Hook v2.0
---------------------------------------
local HJ = {}
HJ.J = {}
HJ.H = {}

function HJ.add_file()
    local file = vim.api.nvim_buf_get_name(0)
    local count = vim.v.count1
    if (vim.bo.buflisted) then
        HJ.H[count] = file 
    end
    HJ.show_file()
end

function HJ.edit_command()
    local count = vim.v.count1
    local message = string.format("Command (%s): ", count) 
    local default = HJ.J[count] or ""
    function command_callback(command)
        if command ~= nil then
            HJ.J[count] = command
        end
    end
    vim.ui.input({ prompt = message, completion = "command", default = default }, command_callback)
end

function HJ.show_file()
    local count = vim.v.count1
    local path = string.gsub(HJ.H[count] or "-", vim.env.HOME, "~", 1)
    local message = string.format("hook (%s): %s", count, path)
    vim.notify(message, vim.log.levels.INFO)
end

function HJ.edit_file()
    local count = vim.v.count1

    if vim.fn.filereadable(HJ.H[count]) == 1 then
        vim.cmd.edit(HJ.H[count])
    end
end

function HJ.run_command()
    local count = vim.v.count1
    return string.format("<cmd>%s<CR>", HJ.J[count])
end

vim.keymap.set("n", "<leader>hs", HJ.show_file)
vim.keymap.set("n", "<leader>hl", HJ.add_file)
vim.keymap.set("n", "<leader>hh", HJ.edit_file)
vim.keymap.set("n", "<leader>jk", HJ.edit_command)
vim.keymap.set("n", "<leader>jj", HJ.run_command, { expr = true })


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
