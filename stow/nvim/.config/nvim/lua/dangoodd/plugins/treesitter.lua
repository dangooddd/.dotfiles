return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        local langs = {}
        for _, value in ipairs(require("nvim-treesitter").get_available()) do
            langs[value] = true
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function(event)
                local ok, _ = pcall(vim.treesitter.start, event.buf)
                if not ok then
                    local lang = vim.treesitter.language.get_lang(event.match)
                    if langs[lang] then
                        require("nvim-treesitter").install(lang)
                    end
                end
            end,
        })
    end,
}
