local M = {}

local lazygit = require("terminal").new({
    cmd = "lazygit",
    open_win = function(buf)
        local total_width = vim.o.columns
        local total_height = vim.o.lines - vim.o.cmdheight

        if
            vim.o.showtabline == 2
            or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
        then
            total_height = total_height - 1
        end

        if
            vim.o.laststatus >= 2
            or (vim.o.laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1)
        then
            total_height = total_height - 1
        end

        local width = math.min(total_width - 6, math.floor(total_width * 0.8))
        local height = total_height - 4

        local win = vim.api.nvim_open_win(buf, false, {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((total_height - height) / 2),
            col = math.floor((total_width - width) / 2) - 1,
            border = vim.o.winborder,
        })

        return win
    end,
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

function M.setup()
    local complete = function(arglead)
        local items = { "toggle", "close" }
        return vim.tbl_filter(function(item)
            return vim.startswith(item, arglead)
        end, items)
    end

    vim.api.nvim_create_user_command("Lazygit", function(o)
        if o.args == "toggle" then
            M.toggle()
        elseif o.args == "close" then
            M.close()
        else
            error("[lazygit] unknown command: " .. o.args)
        end
    end, { nargs = 1, complete = complete })
end

return M
