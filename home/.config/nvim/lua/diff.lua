local M = {}
local tab

---@param left string
---@param right string
---@param client integer
function M.open(left, right, client)
    if tab and vim.api.nvim_tabpage_is_valid(tab) then
        vim.api.nvim_set_current_tabpage(tab)
    else
        tab = vim.api.nvim_open_tabpage(vim.api.nvim_create_buf(false, true), true, {})
    end
    local cur = tab

    vim.api.nvim_create_autocmd({ "TabClosed", "VimLeavePre" }, {
        callback = function(event)
            if event.event == "VimLeavePre"
                or not vim.api.nvim_tabpage_is_valid(cur)
            then
                vim.rpcnotify(client, "nvim_command", "qa!")
                return true
            end
        end,
    })

    vim.api.nvim_create_autocmd("TabClosedPre", {
        callback = function()
            if vim.api.nvim_get_current_tabpage() == cur then
                vim.cmd("diffoff!")
                return true
            end
        end,
    })

    require("difftool").open(left, right)
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(cur)) do
        vim.bo[vim.api.nvim_win_get_buf(win)].bufhidden = "wipe"
    end
end

if ... == "diff" then
    return M
end

local channel = vim.fn.sockconnect("pipe", vim.env.NVIM, { rpc = true })
vim.rpcrequest(channel, "nvim_exec_lua", "require('diff').open(...)", {
    vim.fs.abspath(arg[1]),
    vim.fs.abspath(arg[2]),
    vim.rpcrequest(channel, "nvim_get_api_info")[1],
})

vim.wait(math.huge)
