local M = {}
local utils = require("utils")

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

local ipython = require("terminal").new({
    cmd = vim.list_extend({ "python3" }, args),
    env = { PYDEVD_DISABLE_FILE_VALIDATION = 1 },
})

local compound_top_level_nodes = {
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

function M.install()
    vim.cmd(string.format("!%s install %s", table.concat(pip, " "), table.concat(packages, " ")))
end

--------------------------------------------------------------------------------
-- REPL
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- Send
--------------------------------------------------------------------------------

---@param message string
local function normalize_python(message)
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

function M.send()
    local start_idx = vim.fn.line("v")
    local end_idx = vim.fn.line(".")

    if start_idx > end_idx then
        start_idx, end_idx = end_idx, start_idx
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_idx - 1, end_idx, false)
    local normalized = normalize_python(table.concat(lines, "\n"))

    ipython:send(utils.wrap_bracketed(normalized) .. "\n")
    ipython:scroll()
    vim.cmd.normal({ vim.keycode([[<C-\><C-N>]]), bang = true })
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()
    if vim.fn.executable("uv") == 1 then
        pip = { "uv", "pip" }
        ipython.cmd = vim.list_extend({ "uv", "run" }, args)
    end
end

return M
