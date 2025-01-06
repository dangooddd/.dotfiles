return {
    "stevearc/conform.nvim",
    event = "BufWritePre",  -- load before writing
    config = function()
        require("conform").setup({
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

        vim.keymap.set("n", "<leader>at", function()
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            local message = "autoformat: "
            if vim.b.disable_autoformat then 
                message = message.."disabled"
            else
                message = message.."enabled"
            end
            vim.notify(message, vim.log.levels.INFO)
        end)
    end,
}
