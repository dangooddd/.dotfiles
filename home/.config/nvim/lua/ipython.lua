local M = {}
local utils = require("utils")

local packages = { "ipython", "pynvim" }
local pip = { "python3", "-m", "pip" }
local args = {
    "-m",
    "IPython",
    "--InteractiveShellApp.exec_files",
    vim.api.nvim_get_runtime_file("runtime/ipython.py", false)[1],
}

local ipython = require("terminal").new({
    cmd = vim.list_extend({ "python3" }, args),
    env = { PYDEVD_DISABLE_FILE_VALIDATION = 1 },
})

function M.install()
    vim.cmd(string.format("!%s install %s", table.concat(pip, " "), table.concat(packages, " ")))
end

function M.open()
    for _, pkg in ipairs(packages) do
        local ok, installed = pcall(function()
            local cmd = vim.list_extend(vim.list_extend({}, pip), { "show", pkg })
            return vim.system(cmd):wait().code == 0
        end)

        if not ok or not installed then
            error(string.format("[ipython] failed to start: package `%s` is not installed", pkg), 0)
        end
    end

    ipython:open()
end

function M.focus()
    ipython:focus()
end

function M.hide()
    ipython:hide()
end

function M.close()
    ipython:close()
end

function M.toggle()
    if ipython.win and vim.api.nvim_win_is_valid(ipython.win) then
        M.hide()
    else
        M.open()
    end
end

function M.send()
    local start_idx = vim.fn.line("v")
    local end_idx = vim.fn.line(".")

    if start_idx > end_idx then
        start_idx, end_idx = end_idx, start_idx
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_idx - 1, end_idx, false)
    local text = table.concat(lines, "\n"):gsub("^%s*\n", ""):gsub("\n%s*$", "") .. "\n"

    ipython:send(utils.wrap_bracketed(text) .. "\n")
    ipython:scroll()
    vim.cmd.normal({ vim.keycode([[<C-\><C-N>]]), bang = true })
end

function M.setup()
    if vim.fn.executable("uv") == 1 then
        pip = { "uv", "pip" }
        ipython.cmd = vim.list_extend({ "uv", "run" }, args)
    end
end

return M
