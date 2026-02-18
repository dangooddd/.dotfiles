return {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- load before writing
    cmd = "ConformInfo",
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                python = { "ruff_format", "ruff_organize_imports" },
                lua = { "stylua" },
            },
            format_after_save = function(bufnr)
                if not vim.b[bufnr].conform_stop then
                    return {
                        lsp_format = "fallback",
                    }
                end
            end,
        })

        vim.api.nvim_create_user_command("ConformToggle", function()
            vim.b.conform_stop = not vim.b.conform_stop
        end, {})
    end,
}
