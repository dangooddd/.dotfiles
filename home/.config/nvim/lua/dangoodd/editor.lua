---------------------------------------
-- Usable functions
---------------------------------------
local function centering_toggle()
    local goff = vim.api.nvim_get_option_value("scrolloff", { scope = "global" }) 
    local loff = vim.api.nvim_get_option_value("scrolloff", { scope = "local" }) 
    if loff ~= 999 then
        vim.opt_local.scrolloff = 999
    else
        vim.opt_local.scrolloff = goff
    end
end
-- center editor view
vim.keymap.set("n", "<leader>c", centering_toggle)

function background_toggle()
    local background = vim.api.nvim_get_option_value("background", { scope = "global" })
    if background== "dark" then
        vim.opt.background = "light"
    else
        vim.opt.background = "dark"
    end
end
-- toggle dark/light background
vim.keymap.set("n", "<leader>l", background_toggle)
