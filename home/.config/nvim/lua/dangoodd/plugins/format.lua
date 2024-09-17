return {
    "stevearc/conform.nvim",
    event = "BufWritePre",  -- load before writing
    config = function()
        require("conform").setup({
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            }
        })
    end,
}
