local group = vim.api.nvim_create_augroup("AutoCentering", {})

local function center(mode) 
    mode = mode or nil
    local curwants = vim.fn.getcurpos()[5]  -- save curwants
    vim.cmd("norm! zz")  -- centering command
    if mode == "insert" then
        local pos = vim.fn.getcurpos()
        -- col should be curwants (for current line) 
        -- for proper work of last col
        local col = pos[5]
        local off = pos[4]
        local row = pos[1]
        vim.fn.cursor({ row, col, off, curwants })
    end
end

local function enable_centering()
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = 0,
        callback = function(args)
            center()
        end
    })

    vim.api.nvim_create_autocmd("CursorMovedI", {
        group = group,
        buffer = 0,
        callback = function(args)
            center("insert")
        end
    })

    vim.b.auto_centering = 1
end

local function disable_centering()
    vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
    vim.b.auto_centering = 0
end

local function toggle_centering()
    if vim.b.auto_centering == 1 then
        disable_centering()
    else
        enable_centering()
    end
end

vim.keymap.set("n", "<leader>c", toggle_centering)
enable_centering()
