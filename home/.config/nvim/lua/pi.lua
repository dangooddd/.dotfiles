local M = {}

local utils = require("utils")
local pi = require("terminal").new({ cmd = "pi" })

function M.open()
    pi:open()
end

function M.close()
    pi:close()
end

function M.toggle()
    pi:toggle()
end

function M.focus()
    pi:focus()
end

function M.send()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        error("[pi] current buffer has no file path", 0)
    end

    local line = vim.api.nvim_win_get_cursor(0)[1]
    local location = string.format("%s:%d", vim.fn.fnamemodify(path, ":p"), line)

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
