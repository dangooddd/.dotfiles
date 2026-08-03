local M = {}

local utils = require("utils")
local pi = require("terminal").new({ cmd = "pi" })

function M.open()
    pi:open()
end

function M.hide()
    pi:hide()
end

function M.close()
    pi:close()
end

function M.toggle()
    if pi.win and vim.api.nvim_win_is_valid(pi.win) then
        M.hide()
    else
        M.open()
    end
end

function M.focus()
    pi:focus()
end

function M.send()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        error("[pi] current buffer has no file path", 0)
    end

    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    local location = string.format("%s#L%d", vim.fn.fnamemodify(path, ":p"), start_line)
    if end_line ~= start_line then
        location = string.format("%s-L%d", location, end_line)
    end

    pi:open()
    pi:send(utils.wrap_bracketed(location))
    pi:scroll()
end

function M.setup()
    local complete = function(arglead)
        local items = { "open", "close", "toggle", "focus", "send" }
        return vim.tbl_filter(function(item)
            return vim.startswith(item, arglead)
        end, items)
    end

    vim.api.nvim_create_user_command("Pi", function(o)
        if o.args == "open" then
            M.open()
        elseif o.args == "close" then
            M.close()
        elseif o.args == "toggle" then
            M.toggle()
        elseif o.args == "focus" then
            M.focus()
        elseif o.args == "send" then
            M.send()
        else
            error("[pi] unknown command: " .. o.args)
        end
    end, { nargs = 1, complete = complete })
end

return M
