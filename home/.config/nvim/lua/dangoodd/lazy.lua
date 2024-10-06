---------------------------------------
-- Bootstrap lazy plugin manager
---------------------------------------
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazy_path) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazy_path,
    })
end
vim.opt.rtp:prepend(lazy_path)

-- lazy config
require("lazy").setup({
    spec = {
        { import = "dangoodd.plugins" }
    },
    install = {
        missing = true,
        colorscheme = { "kanagawa" },
    },
    change_detection = {
        enable = true,
        notify = false,
    },
    ui = {
        border = "single",
        backdrop = 100,
    },
})
