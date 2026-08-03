---@class TerminalOptions
---@field cmd string|string[] Command passed to `jobstart`.
---@field env? table<string, string|integer>
---@field cwd? string
---@field open_win? fun(buf: integer): integer
---@field on_exit? fun(terminal: Terminal, code: integer, event: string)

---@class Terminal
---@field cmd string|string[]
---@field env? table<string, string|integer>
---@field cwd? string
---@field open_win fun(buf: integer): integer
---@field on_exit fun(terminal: Terminal, code: integer, event: string)
---@field chan integer|nil
---@field buf integer|nil
---@field win integer|nil
---@field closing boolean
---@field group integer
---@field ns integer
local Terminal = {}
Terminal.__index = Terminal

local next_id = 0

---@param buf integer
---@return integer
local function default_open_win(buf)
    return vim.api.nvim_open_win(buf, false, {
        win = -1,
        style = "minimal",
        width = math.floor(vim.o.columns * 0.5),
        split = "right",
    })
end

---@param terminal Terminal
local function default_on_exit(terminal, _, _)
    vim.on_key(function()
        vim.on_key(nil, terminal.ns)
        terminal:close()
    end, terminal.ns)
end

---@param open_win fun(buf: integer): integer
---@return fun(buf: integer): integer
local function wrap_open_win(open_win)
    return function(buf)
        local win = open_win(buf)
        if not (win and vim.api.nvim_win_is_valid(win)) then
            error("[terminal] opened window is invalid", 0)
        end
        return win
    end
end

---@param opts TerminalOptions
---@return Terminal
function Terminal.new(opts)
    vim.validate({
        opts = { opts, "table" },
        cmd = { opts and opts.cmd, { "string", "table" } },
        open_win = { opts and opts.open_win, "function", true },
        on_exit = { opts and opts.on_exit, "function", true },
    })

    next_id = next_id + 1

    return setmetatable({
        cmd = opts.cmd,
        env = opts.env,
        cwd = opts.cwd,
        open_win = wrap_open_win(opts.open_win or default_open_win),
        on_exit = opts.on_exit or default_on_exit,
        chan = nil,
        buf = nil,
        win = nil,
        closing = false,
        group = vim.api.nvim_create_augroup("Terminal" .. next_id, { clear = true }),
        ns = vim.api.nvim_create_namespace("Terminal" .. next_id),
    }, Terminal)
end

---@private
function Terminal:_setup_buf_autocmds()
    assert(self.buf)

    vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = self.group,
        buffer = self.buf,
        callback = function()
            self.buf = nil
            self:close()
        end,
        once = true,
    })
end

---@private
function Terminal:_setup_win_autocmds()
    assert(self.win)

    vim.api.nvim_clear_autocmds({
        event = "WinClosed",
        group = self.group,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = self.group,
        pattern = tostring(self.win),
        callback = function()
            self:hide()
        end,
        once = true,
    })
end

function Terminal:open()
    if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
        if not (self.win and vim.api.nvim_win_is_valid(self.win)) then
            self.win = self.open_win(self.buf)
            self:_setup_win_autocmds()
        end
        return
    end

    self.buf = vim.api.nvim_create_buf(false, true)
    self.win = self.open_win(self.buf)
    vim.bo[self.buf].bufhidden = "hide"

    local terminal = self
    vim.api.nvim_buf_call(self.buf, function()
        terminal.chan = vim.fn.jobstart(terminal.cmd, {
            term = true,
            env = terminal.env,
            cwd = terminal.cwd,
            on_exit = vim.schedule_wrap(function(_, code, event)
                terminal:on_exit(code, event)
            end),
        })
    end)

    if self.chan == 0 or self.chan == -1 then
        self:close()
        error("[terminal] failed to start command", 0)
    end

    self:_setup_buf_autocmds()
    self:_setup_win_autocmds()
end

function Terminal:hide()
    local win = self.win
    self.win = nil

    if win and vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_close, win, true)
    end
end

function Terminal:close()
    if self.closing then
        return
    end

    self.closing = true
    self:hide()

    if self.chan and self.chan > 0 then
        pcall(vim.fn.jobstop, self.chan)
    end

    if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
        pcall(vim.api.nvim_buf_delete, self.buf, { force = true })
    end

    self.chan = nil
    self.buf = nil
    self.win = nil
    self.closing = false
end

function Terminal:focus()
    if not self.buf then
        return
    end

    self:open()
    assert(self.win)

    if vim.api.nvim_get_current_win() == self.win then
        vim.cmd.stopinsert()
        vim.cmd.wincmd("p")
    else
        vim.api.nvim_set_current_win(self.win)
        vim.cmd.startinsert()
    end
end

---@param message string
function Terminal:send(message)
    if self.chan then
        vim.api.nvim_chan_send(self.chan, message)
    end
end

function Terminal:scroll()
    if self.win and vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_call(self.win, function()
            vim.cmd.normal({ "G", bang = true })
        end)
    end
end

return Terminal
