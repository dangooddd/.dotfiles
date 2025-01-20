return {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- load before writing
    cmd = "ConformInfo",
    keys = { "<leader>tf" },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                python = { "black" },
            },
            format_on_save = function(bufnr)
                if vim.b[bufnr].disable_autoformat then
                    return
                end

                return {
                    timeout_ms = 500,
                    lsp_format = "fallback"
                }
            end,
        })

        vim.keymap.set("n", "<leader>tf", function()
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            local message = "enabled"
            if vim.b.disable_autoformat then
                message = "disabled"
            end
            vim.notify("Autoformat: " .. message, vim.log.levels.INFO)
        end)
    end,
}
