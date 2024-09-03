---------------------------------------
-- Bootstrap lazy plugin manager
---------------------------------------
local lazy_path = vim.fn.stdpath("data").."/lazy/lazy.nvim"
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

require("lazy").setup({
    spec = { 
        { import = "dangoodd.plugins" } 
    },
    lockfile = vim.fn.stdpath("config") .. "/lua/dangoodd/lazy-lock.json",
    install = {
        missing = true,
        colorscheme = { "kanagawa" },
    },
})
