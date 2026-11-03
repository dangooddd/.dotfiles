local M = {}

local floaterm = require("terminal").new({
    cmd = { vim.o.shell },
    open_win = require("utils").open_float_win,
    on_exit = function(self, _, _)
        self:close()
    end,
})

function M.toggle()
    if floaterm.win and vim.api.nvim_win_is_valid(floaterm.win) then
        floaterm:hide()
    else
        floaterm:open()
        floaterm:focus()
    end
end

function M.close()
    floaterm:close()
end

return M
