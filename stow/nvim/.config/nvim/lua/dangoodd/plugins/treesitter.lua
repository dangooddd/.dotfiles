return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        -- lookup table
        local langs = {}
        for _, value in ipairs(require("nvim-treesitter").get_available()) do
            langs[value] = true
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = vim.schedule_wrap(function(event)
                -- check is language has supported parser
                local lang = vim.treesitter.language.get_lang(event.match)
                if not langs[lang] then
                    return
                end

                -- start treesitter
                local ok, _ = pcall(vim.treesitter.start, event.buf)
                if not ok then
                    require("nvim-treesitter").install(lang)
                end
            end),
        })
    end,
}
