local group = vim.api.nvim_create_augroup("AutoCentering", {})

local function center(mode) 
    mode = mode or nil
    local pos = vim.fn.getcurpos()
    local line = pos[2]
    local off = pos[3]
    local curwants = pos[5]
    if vim.b.centering_last_line == nil then
        vim.b.centering_last_line = line
    end
    local lline = vim.b.centering_last_line

    -- don't center after scroll
    local top = vim.fn.line("w0") + vim.o.scrolloff
    local bot = vim.fn.line("w$") - vim.o.scrolloff
    if ((line <= top and line > lline) or (line >= bot and line < lline)) then
        -- center when cursor on bottom of buffer
        local botg = vim.fn.line("$") - vim.o.scrolloff
        if not (line >= botg and lline > line) then
            vim.b.centering_last_line = line
            return
        end
    end

    if line ~= lline then
        vim.cmd("norm! zz")  -- centering command
        vim.b.centering_last_line = line

        if mode == "insert" then
            -- correction for insert node
            -- without this will jump one 
            -- char before correct char
            local col = vim.fn.getcurpos()[5]
            vim.fn.cursor({ line, col, off, curwants })
        end
    end
end

local function enable_centering()
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = 0,
        callback = function(args)
            center()
        end,
    })

    vim.api.nvim_create_autocmd("CursorMovedI", {
        group = group,
        buffer = 0,
        callback = function(args)
            center("insert")
        end,
    })

    vim.b.centering = 1
end

local function disable_centering()
    vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })
    vim.b.centering = 0
end

local function toggle_centering()
    if vim.b.centering == 1 then
        disable_centering()
    else
        enable_centering()
    end
end

vim.keymap.set("n", "<leader>c", toggle_centering)

-- enable by default
vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "*",
    callback = function()
        if vim.bo.buflisted then
            enable_centering()
        end
    end,
})
