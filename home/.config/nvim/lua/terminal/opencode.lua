local M = {}

local utils = require("utils")
local opencode = require("terminal").new({ cmd = "opencode" })

function M.close()
    opencode:close()
end

function M.toggle()
    if opencode.win and vim.api.nvim_win_is_valid(opencode.win) then
        opencode:hide()
    else
        opencode:open()
    end
end

function M.focus()
    opencode:focus()
end

function M.send()
    local path = vim.api.nvim_buf_get_name(0)
    local absolute_path = vim.fn.fnamemodify(path, ":p")
    local relative_path = vim.fs.relpath(opencode.cwd or vim.fn.getcwd(), absolute_path)

    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    if start_line > end_line then
        start_line, end_line = end_line, start_line
    end

    local location = string.format("%s#L%d", relative_path or absolute_path, start_line)
    if end_line ~= start_line then
        location = string.format("%s-L%d", location, end_line)
    end

    opencode:open()
    opencode:send(utils.wrap_bracketed(location))
    opencode:scroll()
end

return M
