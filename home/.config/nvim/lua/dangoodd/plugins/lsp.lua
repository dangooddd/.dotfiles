return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
    },
    lazy = false,
    config = function()
        local cmp = require("cmp")
        -- extend capabilities of nvim in lsp completion
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local handlers =  {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
        }

        require("mason").setup({
            ui = { border = "rounded" }
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "pylsp",
            },
            -- functions to call on start of lsp
            -- basically auto setup of lsp
            handlers = {
                -- default handler
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities, 
                        handlers = handlers,
                    })
                end,
            },
        })

        -- init completion system
        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ["<C-y>"] = cmp.mapping.confirm({ select = true })
            }),
            formatting = {
                format = function(_, item)
                    local content = item.abbr
                    local max_lenght = 20

                    if #content > max_lenght then
                        item.abbr = vim.fn.strcharpart(content, 0, max_lenght) .. ".."
                    end

                    return item
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { nama = "buffer" },
            }),
        })

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "buffer" },
            }),
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline" },
            }),
        })
    end,
}
