---------------------------------------
-- Bootstrap lazy plugin manager
---------------------------------------
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy_path) then
    local out = vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazy_path,
    }, { text = true }):wait()

    if out.code ~= 0 then
        vim.notify(
            string.format("Failed to clone lazy.nvim:\n%s", out.stderr),
            vim.log.levels.ERROR
        )
    end
end
vim.opt.rtp:prepend(lazy_path)

-- lazy config
require("lazy").setup({
    spec = {
        { import = "dangoodd.plugins" }
    },
    install = {
        missing = true,
        colorscheme = { "kanagawa", "retrobox" },
    },
    change_detection = {
        enable = true,
        notify = false,
    },
    ui = {
        border = "rounded",
        backdrop = 100,
    },
})
