return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
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
    },

    {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    {
        "nvim-mini/mini.icons",
        version = "*",
        config = function()
            require("mini.icons").setup()
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function() end,
    },

    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = { backdrop = 100 },
            })
        end,
    },

    {
        "dangooddd/pyrepl.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            local pyrepl = require("pyrepl")
            pyrepl.setup()

            vim.keymap.set("n", "<leader>jo", pyrepl.open_repl)
            vim.keymap.set("n", "<leader>jh", pyrepl.hide_repl)
            vim.keymap.set("n", "<leader>jc", pyrepl.close_repl)
            vim.keymap.set("n", "<leader>ji", pyrepl.open_image_history)
            vim.keymap.set({ "n", "t" }, "<C-j>", pyrepl.toggle_repl_focus)

            vim.keymap.set("n", "<leader>jb", pyrepl.send_buffer)
            vim.keymap.set("n", "<leader>jl", pyrepl.send_cell)
            vim.keymap.set("v", "<leader>jv", pyrepl.send_visual)

            vim.keymap.set("n", "<leader>jp", pyrepl.step_cell_backward)
            vim.keymap.set("n", "<leader>jn", pyrepl.step_cell_forward)
            vim.keymap.set("n", "<leader>je", pyrepl.export_to_notebook)
            vim.keymap.set("n", "<leader>js", ":PyreplInstall")
        end,
    },

    {
        "ibhagwan/fzf-lua",
        event = "VeryLazy",
        config = function()
            local fzf = require("fzf-lua")

            fzf.setup({
                fzf_colors = true,
                winopts = {
                    backdrop = 100,
                    title_flags = false,
                    border = vim.o.winborder,
                    preview = {
                        horizontal = "right:50%",
                        layout = "horizontal",
                        border = vim.o.winborder,
                    },
                },
            })

            vim.keymap.set("n", "<leader>ff", fzf.files)
            vim.keymap.set("n", "<leader>fh", fzf.helptags)
            vim.keymap.set("n", "<leader>fb", fzf.buffers)
            vim.keymap.set("n", "<leader>fg", fzf.git_files)
            vim.keymap.set("n", "<leader>fd", fzf.diagnostics_workspace)
            vim.keymap.set("n", "<leader>fl", fzf.live_grep)
            vim.keymap.set("n", "<leader>fz", fzf.builtin)
            vim.keymap.set("n", "<leader>fr", fzf.resume)
        end,
    },

    {
        "stevearc/oil.nvim",
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                columns = { { "icon", add_padding = false } },
                view_options = { show_hidden = true },
                float = {
                    max_width = 0.8,
                    preview_split = "right",
                    win_options = { winhighlight = "NormalNC:NormalFloat" },
                },
                keymaps = { ["q"] = { "actions.close", mode = "n" } },
            })

            vim.keymap.set("n", [[\]], require("oil").toggle_float)
        end,
    },

    {

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
                callback = vim.schedule_wrap(function(event)
                    local lang = vim.treesitter.language.get_lang(event.match)
                    if not langs[lang] then
                        return
                    end

                    local ok, _ = pcall(vim.treesitter.start, event.buf)
                    if not ok then
                        require("nvim-treesitter").install(lang)
                    end
                end),
            })
        end,
    },
}
