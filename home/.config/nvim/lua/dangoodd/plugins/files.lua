return {
    "echasnovski/mini.files",
    version = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("mini.files").setup({
            mappings = {
                go_out_plus = "-",
                go_out = "H",
                go_in_plus = "<CR>",
                go_in = "L",
            }
        })

        -- change working directory to mini.files
        -- current path
        local function files_cwd()
            local entry_path = MiniFiles.get_fs_entry().path
            local entry_dir = vim.fs.dirname(entry_path)
            local message = "files: cd "..vim.fn.fnamemodify(entry_dir, ":~")
            vim.fn.chdir(entry_dir)
            vim.notify(message, vim.log.levels.INFO)
        end

        -- toggle mini.files
        local function files_toggle()
            if not MiniFiles.close() then 
                MiniFiles.open()
            end
        end

        -- split view and make new window
        -- be target of mini.files
        local function files_split(direction)
            return function()
                local cur_target = MiniFiles.get_explorer_state().target_window
                local new_target = vim.api.nvim_win_call(cur_target, function()
                    vim.cmd(direction .. ' split')
                    return vim.api.nvim_get_current_win()
                end)
                MiniFiles.set_target_window(new_target)
            end
        end

        vim.keymap.set("n", [[<leader>\]], files_toggle)

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buffer = args.data.buf_id
                local files_hor_split = files_split("belowright horizontal")
                local files_ver_split = files_split("belowright vertical")
                vim.keymap.set("n", "g~", files_cwd, { buffer = buffer })
                vim.keymap.set("n", "<C-s>", files_hor_split, { buffer = buffer })
                vim.keymap.set("n", "<C-v>", files_ver_split, { buffer = buffer })
            end,
        })
    end
}
