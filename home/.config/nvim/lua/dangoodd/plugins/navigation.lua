return {
    -- picker
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("fzf-lua").setup({
                fzf_colors = true,
                winopts = {
                    backdrop = 100,
                    preview = {
                        horizontal = "right:40%",
                        layout = "horizontal",
                    }
                },
                grep = {
                    cmd = "rg --hidden",
                },
            })

            local fzf = require("fzf-lua")
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

    -- track visited files
    {
        "echasnovski/mini.visits",
        event = "VeryLazy",
        config = function()
            require("mini.visits").setup({
                track = {
                    delay = 500,
                },
            })

            -- fixed label keybinds
            vim.keymap.set("n", ";", function()
                MiniVisits.add_label("core")
            end)

            vim.keymap.set("n", "<leader>;", function()
                MiniVisits.remove_label("core")
            end)

            vim.keymap.set("n", "<Enter>", function()
                MiniVisits.select_path(nil, { filter = "core" })
            end)

            -- zoxide-like navigation
            vim.keymap.set("n", "<leader>z", function()
                MiniVisits.select_path("", {
                    sort = MiniVisits.gen_sort.z()
                })
            end)

            -- any label keybinds
            vim.keymap.set("n", "<leader>va", MiniVisits.add_label)
            vim.keymap.set("n", "<leader>vp", MiniVisits.select_label)
            vim.keymap.set("n", "<leader>vr", MiniVisits.remove_label)
        end,
    },
}
