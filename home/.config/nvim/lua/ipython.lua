local M = {}

local placeholders = require("placeholders")
local Terminal = require("terminal")
local utils = require("utils")
local group = vim.api.nvim_create_augroup("IPython", { clear = true })
local ns = vim.api.nvim_create_namespace("IPython")

local packages = { "ipython", "pynvim" }
local pip = { "python3", "-m", "pip" }
local args = {
    "-m",
    "IPython",
    "--TerminalInteractiveShell.true_color",
    vim.o.termguicolors and "True" or "False",
    "--InteractiveShellApp.exec_files",
    vim.api.nvim_get_runtime_file("runtime/ipython.py", false)[1],
}

local repl = Terminal.new({
    cmd = vim.list_extend({ "python3" }, args),
    env = { PYDEVD_DISABLE_FILE_VALIDATION = 1 },
})

---@class IPythonHistory
---@field closing boolean
---@field images PlaceholdersImage[]
---@field idx integer
---@field buf integer|nil
---@field win integer|nil
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

function M.install_packages()
    vim.cmd(string.format("!%s install %s", table.concat(pip, " "), table.concat(packages, " ")))
end

--------------------------------------------------------------------------------
-- REPL
--------------------------------------------------------------------------------

function M.open_repl()
    for _, pkg in ipairs(packages) do
        local ok, installed = pcall(function()
            local cmd = vim.list_extend(vim.list_extend({}, pip), { "show", pkg })
            return vim.system(cmd):wait().code == 0
        end)

        if not ok or not installed then
            error(string.format("[ipython] failed to start: package `%s` is not installed", pkg), 0)
        end
    end

    repl:open()
end

function M.toggle_repl_focus()
    repl:focus()
end

function M.hide_repl()
    repl:hide()
end

function M.close_repl()
    repl:close()
end

function M.toggle_repl()
    if repl.win and vim.api.nvim_win_is_valid(repl.win) then
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
function history:_open_win(buf)
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
function history:pop(idx)
    if self.images[idx] then
        self.images[idx]:delete()
        table.remove(self.images, idx)
        self.idx = math.min(self.idx, #self.images)
    end
end

---@param img_base64 string
function history:push(img_base64)
    if #self.images >= 10 then
        self:pop(1)
    end
    table.insert(self.images, placeholders.new(img_base64))
end

function history:_setup_buf_autocmds()
    if not self.buf then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = { "BufWipeout", "BufDelete" },
        group = group,
        buffer = self.buf,
    })

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = group,
        buffer = self.buf,
        callback = function()
            self:close()
        end,
        once = true,
    })
end

function history:_setup_win_autocmds()
    if not self.win then
        return
    end

    vim.api.nvim_clear_autocmds({
        event = "WinClosed",
        group = group,
        pattern = tostring(self.win),
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(self.win),
        callback = function()
            self:close()
        end,
        once = true,
    })
end

function history:_setup_keybinds()
    if not self.buf then
        return
    end

    local opts = {
        noremap = true,
        silent = true,
        nowait = true,
        buffer = self.buf,
    }

    local function show_previous()
        if self.idx > 1 then
            self:open(self.idx - 1, true)
        end
    end

    local function show_next()
        if self.idx < #self.images then
            self:open(self.idx + 1, true)
        end
    end

    vim.keymap.set("n", "j", show_previous, opts)
    vim.keymap.set("n", "h", show_previous, opts)
    vim.keymap.set("n", "k", show_next, opts)
    vim.keymap.set("n", "l", show_next, opts)

    vim.keymap.set("n", "dd", function()
        self:pop(self.idx)
        if #self.images == 0 then
            vim.cmd(":q")
        else
            self:open(self.idx)
        end
    end, opts)

    vim.keymap.set("n", "q", "<Cmd>:q<CR>", opts)
    vim.keymap.set("n", "<Esc>", "<Cmd>:q<CR>", opts)
end

function history:close()
    if self.closing then
        return
    end

    self.closing = true
    vim.on_key(nil, ns)

    if self.images[self.idx] then
        self.images[self.idx]:clear()
    end

    if self.buf then
        pcall(vim.cmd.bdelete, self.buf)
        self.buf = nil
    end

    if self.win then
        pcall(vim.api.nvim_win_close, self.win, true)
        self.win = nil
    end

    self.closing = false
end

---@param idx? integer
---@param focus? boolean defaults to true
function history:open(idx, focus)
    if #self.images == 0 then
        vim.notify("[ipython] no image history available", vim.log.levels.WARN)
        return
    end

    if self.images[self.idx] then
        self.images[self.idx]:clear()
    end
    self.idx = math.max(1, math.min(idx or self.idx, #self.images))

    if not self.buf then
        self.buf = vim.api.nvim_create_buf(false, true)
        self:_setup_buf_autocmds()
        self:_setup_keybinds()
    end

    if not self.win then
        self.win = self:_open_win(self.buf)
        self:_setup_win_autocmds()
    else
        vim.api.nvim_win_set_buf(self.win, self.buf)
    end

    local title = string.format(" History %d/%d ", self.idx, #self.images)
    vim.api.nvim_win_set_config(self.win, { title = title, title_pos = "center" })

    if focus or focus == nil then
        vim.on_key(nil, ns)
        vim.api.nvim_set_current_win(self.win)
    else
        vim.on_key(function()
            vim.on_key(nil, ns)
            self:close()
        end, ns)
    end

    self.images[self.idx]:render(self.buf, self.win)
end

function M.close_history()
    history:close()
end

---@param idx? integer
---@param focus? boolean defaults to true
function M.open_history(idx, focus)
    history:open(idx, focus)
end

---@param img_base64 string
function M.image_handler(img_base64)
    history:push(img_base64)
    history:open(#history.images, false)
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

---@param terminal Terminal
---@param start_idx integer
---@param end_idx integer
local send_range = vim.schedule_wrap(function(terminal, start_idx, end_idx)
    if start_idx > end_idx then
        start_idx, end_idx = end_idx, start_idx
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_idx - 1, end_idx, false)
    local normalized = normalize_python_message(table.concat(lines, "\n"))
    terminal:send(utils.wrap_bracketed(normalized) .. "\n")
    terminal:scroll()
end)

function M.send_visual()
    local start_idx = vim.fn.line("v")
    local end_idx = vim.fn.line(".")
    send_range(repl, start_idx, end_idx)
    vim.api.nvim_input([[<C-\><C-N>]])
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()
    if vim.fn.executable("uv") == 1 then
        pip = { "uv", "pip" }
        repl.cmd = vim.list_extend({ "uv", "run" }, args)
    end

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
            error("[ipython] unknown command: " .. o.args, 0)
        end
    end, { nargs = 1, complete = complete })
end

return M
