local M = {}

local lazygit = require("terminal").new({
    cmd = "lazygit",
    open_win = require("utils").open_float_win,
    on_exit = function(self, _, _)
        self:close()
    end,
})

function M.toggle()
    if lazygit.win and vim.api.nvim_win_is_valid(lazygit.win) then
        lazygit:hide()
    else
        lazygit:open()
        lazygit:focus()
    end
end

function M.close()
    lazygit:close()
end

return M
