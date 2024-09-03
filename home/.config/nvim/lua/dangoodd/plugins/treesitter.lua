return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function() 
        require("nvim-treesitter.configs").setup({
            ensure_installed = { 
                "bash",
                "c", 
                "lua", 
                "luadoc",
                "diff",
                "html",
                "markdown",
                "vim",
                "vimdoc", 
                "query", 
            },
            sync_install = true,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        })
    end,
}
