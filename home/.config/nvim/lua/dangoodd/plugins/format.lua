return {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- load before writing
    cmd = "ConformInfo",
    keys = { "<leader>tf" },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                python = { "black" },
                gdscript = { "gdformat" },
            },
            format_after_save = function(bufnr)
                if not vim.b[bufnr].conform_disable then
                    return {
                        lsp_format = "fallback"
                    }
                end
            end,
        })

        vim.keymap.set("n", "<leader>tf", function()
            vim.b.conform_disable = not vim.b.conform_disable
            local status = vim.b.conform_disable and "disabled" or "enabled"
            vim.notify("Autoformat " .. status, vim.log.levels.INFO)
        end)
    end,
}
