local M = {}

local placeholders = require("placeholders")
local group = vim.api.nvim_create_augroup("IPython", { clear = true })
local ns = vim.api.nvim_create_namespace("IPython")

---@class IPythonState
---@field closing boolean
---@field hiding boolean
---@field chan integer
---@field buf integer
---@field win integer|nil

---@type IPythonState|nil
local repl = nil

---@class IPythonImages
---@field closing boolean
---@field images PlaceholdersImage[]
---@field idx integer
---@field buf integer|nil
---@field win integer|nil

---@type IPythonImages
local history = {
    images = {},
    closing = false,
    idx = 1,
    buf = nil,
    win = nil,
}

local compound_top_level_nodes = {
    async_for_statement = true,
    async_function_definition = true,
    async_with_statement = true,
    class_definition = true,
    decorated_definition = true,
    for_statement = true,
    function_definition = true,
    if_statement = true,
    match_statement = true,
    try_statement = true,
    while_statement = true,
    with_statement = true,
}

local packages = { "ipython", "pynvim" }

---@class PythonCommands
---@field pip string[]
---@field run string[]

---@return PythonCommands
local function resolve_python_commands()
    if vim.fn.executable("uv") == 1 then
        return { pip = { "uv", "pip" }, run = { "uv", "run" } }
    elseif vim.fn.executable("python3") == 1 then
        return { pip = { "python3", "-m", "pip" }, run = { "python3" } }
    else
        error("[ipython] neither `python3`, nor `uv` executable was found")
    end
end

function M.install_packages()
    local pip = resolve_python_commands().pip
    vim.cmd(string.format("!%s install %s", table.concat(pip, " "), table.concat(packages, " ")))
end

--------------------------------------------------------------------------------
-- REPL
--------------------------------------------------------------------------------

---@param buf integer
---@return integer
local function create_repl_win(buf)
    return vim.api.nvim_open_win(buf, false, {
        win = -1,
        style = "minimal",
        width = math.floor(vim.o.columns * 0.5),
        split = "right",
    })
end

local function setup_repl_buf_autocmds()
    if not repl then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = { "BufWipeout", "BufDelete" },
        group = group,
        buffer = repl.buf,
    })

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = group,
        buffer = repl.buf,
        callback = function()
            M.close_repl()
        end,
        once = true,
    })
end

local function setup_repl_win_autocmds()
    if not (repl and repl.win) then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = "WinClosed",
        group = group,
        pattern = tostring(repl.win),
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(repl.win),
        callback = function()
            M.hide_repl()
        end,
        once = true,
    })
end

function M.open_repl()
    if repl then
        if not repl.win then
            repl.win = create_repl_win(repl.buf)
            setup_repl_win_autocmds()
        end
        return
    end

    local python = resolve_python_commands()
    local show = vim.list_extend(python.pip, { "show" })

    for _, pkg in ipairs(packages) do
        local ok, installed = pcall(function()
            local cmd = vim.list_extend({}, show)
            return vim.system(vim.list_extend(cmd, { pkg })):wait().code == 0
        end)

        if not ok or not installed then
            error(string.format("[ipython] failed to start: package `%s` is not installed", pkg), 0)
        end
    end

    local buf = vim.api.nvim_create_buf(false, true)
    local win = create_repl_win(buf)
    vim.bo[buf].bufhidden = "hide"

    local cmd = vim.list_extend(python.run, {
        "-m",
        "IPython",
        "--TerminalInteractiveShell.true_color",
        vim.o.termguicolors and "True" or "False",
        "--InteractiveShellApp.exec_files",
        vim.api.nvim_get_runtime_file("runtime/startup.py", false)[1],
    })

    local chan = 0
    vim.api.nvim_buf_call(buf, function()
        chan = vim.fn.jobstart(cmd, {
            term = true,
            env = { PYDEVD_DISABLE_FILE_VALIDATION = 1 },
            on_exit = function()
                vim.on_key(function()
                    vim.on_key(nil, ns)
                    M.close_repl()
                end, ns)
            end,
        })
    end)

    repl = {
        buf = buf,
        win = win,
        chan = chan,
        closing = false,
        hiding = false,
    }

    if chan == 0 or chan == -1 then
        M.close_repl()
        error("[ipython] failed to start: unknown error", 0)
    end

    setup_repl_buf_autocmds()
    setup_repl_win_autocmds()
end

local function scroll_repl()
    if repl and repl.win then
        vim.api.nvim_win_call(repl.win, function()
            vim.cmd.normal({ "G", bang = true })
        end)
    end
end

function M.toggle_repl_focus()
    if not repl then
        return
    end

    M.open_repl()
    assert(repl.win)

    if vim.api.nvim_get_current_win() == repl.win then
        vim.cmd.stopinsert()
        vim.cmd.wincmd("p")
    else
        vim.api.nvim_set_current_win(repl.win)
        vim.cmd.startinsert()
    end
end

function M.hide_repl()
    if not repl or repl.hiding then
        return
    end

    if repl.win then
        repl.hiding = true
        pcall(vim.api.nvim_win_close, repl.win, true)
        repl.win = nil
        repl.hiding = false
    end
end

function M.close_repl()
    if not repl or repl.closing then
        return
    end

    repl.closing = true
    M.hide_repl()
    vim.fn.jobstop(repl.chan)
    pcall(vim.cmd.bdelete, { repl.buf, bang = true })

    repl = nil
end

function M.toggle_repl()
    if repl and repl.win then
        M.hide_repl()
    else
        M.open_repl()
    end
end

--------------------------------------------------------------------------------
-- History
--------------------------------------------------------------------------------

---@param buf integer
---@return integer
local function open_history_win(buf)
    local width = vim.o.columns
    local height = vim.o.lines

    local float_width = math.max(1, math.floor(width * 0.5))
    local float_height = math.max(1, math.floor(height * 0.5))

    -- effective window size (without borders)
    -- subtract 2 to take borders into account
    local opts = {
        relative = "editor",
        width = float_width - 2,
        height = float_height - 2,
        row = 0,
        col = math.max(0, width - float_width),
        style = "minimal",
    }

    return vim.api.nvim_open_win(buf, false, opts)
end

---@param idx integer
local function pop_history(idx)
    if history.images[idx] then
        history.images[idx]:delete()
        table.remove(history.images, idx)
        history.idx = math.min(history.idx, #history.images)
    end
end

---@param img_base64 string
local function push_history(img_base64)
    if #history.images >= 10 then
        pop_history(1)
    end
    table.insert(history.images, placeholders.create(img_base64))
end

local function setup_history_buf_autocmds()
    if not history.buf then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = { "BufWipeout", "BufDelete" },
        group = group,
        buffer = history.buf,
    })

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = group,
        buffer = history.buf,
        callback = function()
            M.close_history()
        end,
        once = true,
    })
end

local function setup_history_win_autocmds()
    if not history.win then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = "WinClosed",
        group = group,
        pattern = tostring(history.win),
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(history.win),
        callback = function()
            M.close_history()
        end,
        once = true,
    })
end

local function setup_history_keybinds()
    if not history.buf then
        return
    end

    local opts = { noremap = true, silent = true, nowait = true, buffer = history.buf }

    -- show previous image
    vim.keymap.set("n", "j", function()
        if history.idx > 1 then
            M.open_history(history.idx - 1, true)
        end
    end, opts)

    vim.keymap.set("n", "h", function()
        if history.idx > 1 then
            M.open_history(history.idx - 1, true)
        end
    end, opts)

    -- show next image
    vim.keymap.set("n", "k", function()
        if history.idx < #history.images then
            M.open_history(history.idx + 1, true)
        end
    end, opts)

    vim.keymap.set("n", "l", function()
        if history.idx < #history.images then
            M.open_history(history.idx + 1, true)
        end
    end, opts)

    -- delete image
    vim.keymap.set("n", "dd", function()
        pop_history(history.idx)
        if #history.images == 0 then
            vim.cmd(":q")
        else
            M.open_history(history.idx)
        end
    end, opts)

    -- exit image
    vim.keymap.set("n", "q", "<Cmd>:q<CR>", opts)
    vim.keymap.set("n", "<Esc>", "<Cmd>:q<CR>", opts)
end

function M.close_history()
    if history.closing then
        return
    end

    history.closing = true
    vim.on_key(nil, ns)

    if history.images[history.idx] then
        history.images[history.idx]:clear()
    end

    if history.buf then
        pcall(vim.cmd.bdelete, history.buf)
        history.buf = nil
    end

    if history.win then
        pcall(vim.api.nvim_win_close, history.win, true)
        history.win = nil
    end

    history.closing = false
end

---@param idx? integer
---@param focus? boolean defaults to true
function M.open_history(idx, focus)
    if #history.images == 0 then
        vim.notify("[ipython] no image history available", vim.log.levels.WARN)
        return
    end

    if history.images[history.idx] then
        history.images[history.idx]:clear()
    end
    history.idx = math.max(1, math.min(idx or history.idx, #history.images))

    if not history.buf then
        history.buf = vim.api.nvim_create_buf(false, true)
        setup_history_buf_autocmds()
        setup_history_keybinds()
    end

    if not history.win then
        history.win = open_history_win(history.buf)
        setup_history_win_autocmds()
    else
        vim.api.nvim_win_set_buf(history.win, history.buf)
    end

    local title = string.format(" History %d/%d ", history.idx, #history.images)
    vim.api.nvim_win_set_config(history.win, { title = title, title_pos = "center" })

    if focus or focus == nil then
        vim.on_key(nil, ns)
        vim.api.nvim_set_current_win(history.win)
    else
        vim.on_key(function()
            vim.on_key(nil, ns)
            M.close_history()
        end, ns)
    end

    history.images[history.idx]:render(history.buf, history.win)
end

---@param img_base64 string
function M.image_handler(img_base64)
    push_history(img_base64)
    M.open_history(#history.images, false)
end

--------------------------------------------------------------------------------
-- Send
--------------------------------------------------------------------------------

---@param message string
local function normalize_python_message(message)
    local lines = vim.split(message, "\n", { plain = true, trimempty = false })
    if #lines <= 1 then
        return message
    end

    local ok, parser = pcall(vim.treesitter.get_string_parser, message, "python")
    local tree = ok and parser and parser:parse()[1]
    local root = tree and tree:root()

    if not root then
        return message
    end

    local nodes, insert_after, has_compound = {}, {}, false

    for node in root:iter_children() do
        if node:named() and node:type() ~= "ERROR" then
            nodes[#nodes + 1] = node
        end
    end

    for i, node in ipairs(nodes) do
        if compound_top_level_nodes[node:type()] then
            has_compound = true

            local _, _, erow, ecol = node:range()
            local last = ecol == 0 and math.max(erow - 1, 0) or erow
            local next_start = nodes[i + 1] and select(1, nodes[i + 1]:range()) or #lines

            local blank = false
            for row = last + 1, next_start - 1 do
                if lines[row + 1]:match("^%s*$") then
                    blank = true
                    break
                end
            end

            if next_start > last and not blank then
                insert_after[last + 1] = true
            end
        end
    end

    if has_compound and not lines[#lines]:match("^%s*$") then
        insert_after[#lines] = true
    end

    if not next(insert_after) then
        return message
    end

    local out = {}
    for i, line in ipairs(lines) do
        out[#out + 1] = line
        if insert_after[i] then
            out[#out + 1] = ""
        end
    end

    return table.concat(out, "\n")
end

---@param chan integer
---@param message string
local raw_send_message = vim.schedule_wrap(function(chan, message)
    -- bracketed paste
    local prefix = "\x1b[200~"
    local suffix = "\x1b[201~"
    local normalized = normalize_python_message(message)
    vim.api.nvim_chan_send(chan, prefix .. normalized .. suffix .. "\n")
end)

function M.send_visual()
    if not repl then
        return
    end

    local start_idx = vim.fn.line("v")
    local end_idx = vim.fn.line(".")

    if start_idx > end_idx then
        start_idx, end_idx = end_idx, start_idx
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_idx - 1, end_idx, false)
    raw_send_message(repl.chan, table.concat(lines, "\n"))
    scroll_repl()
    vim.api.nvim_input([[<C-\><C-N>]])
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()
    local complete = function(arglead)
        local items = { "open", "close", "toggle", "install", "history" }
        return vim.tbl_filter(function(item)
            return vim.startswith(item, arglead)
        end, items)
    end

    vim.api.nvim_create_user_command("IPython", function(o)
        if o.args == "open" then
            M.open_repl()
        elseif o.args == "close" then
            M.close_repl()
        elseif o.args == "toggle" then
            M.toggle_repl()
        elseif o.args == "install" then
            M.install_packages()
        elseif o.args == "history" then
            M.open_history()
        else
            error("[ipython] unknown command: " .. o.args)
        end
    end, { nargs = 1, complete = complete })
end

return M
