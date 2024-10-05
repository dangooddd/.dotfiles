local function toggle_centering()
    local goff = vim.api.nvim_get_option_value("scrolloff", { scope = "global" }) 
    local loff = vim.api.nvim_get_option_value("scrolloff", { scope = "local" }) 
    if  loff ~= 999 then
        vim.opt_local.scrolloff = 999
    else
        vim.opt_local.scrolloff = goff
    end
end

vim.keymap.set("n", "<leader>c", toggle_centering)
