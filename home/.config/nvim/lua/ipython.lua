local M = {}

local placeholders = require("placeholders")
local utils = require("utils")
local group = vim.api.nvim_create_augroup("IPython", { clear = true })

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

local repl = require("terminal").new({
    cmd = vim.list_extend({ "python3" }, args),
    env = { PYDEVD_DISABLE_FILE_VALIDATION = 1 },
})

---@type PlaceholdersImage[]
local images = {}

local function delete_images()
    for _, image in ipairs(images) do
        image:delete()
    end
    images = {}
end

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = delete_images,
})

local compound_top_level_nodes = {
    async_for_statement = true,
    async_function_definition = true,
    async_with_statement = true,
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

function M.install_packages()
    vim.cmd(string.format("!%s install %s", table.concat(pip, " "), table.concat(packages, " ")))
end

--------------------------------------------------------------------------------
-- REPL
--------------------------------------------------------------------------------

function M.open_repl()
    for _, pkg in ipairs(packages) do
        local ok, installed = pcall(function()
            local cmd = vim.list_extend(vim.list_extend({}, pip), { "show", pkg })
            return vim.system(cmd):wait().code == 0
        end)

        if not ok or not installed then
            error(string.format("[ipython] failed to start: package `%s` is not installed", pkg), 0)
        end
    end

    repl:open()
end

function M.toggle_repl_focus()
    repl:focus()
end

function M.hide_repl()
    repl:hide()
end

function M.close_repl()
    repl:close()
end

function M.toggle_repl()
    if repl.win and vim.api.nvim_win_is_valid(repl.win) then
        M.hide_repl()
    else
        M.open_repl()
    end
end

--------------------------------------------------------------------------------
-- Inline images
--------------------------------------------------------------------------------

---@param img_base64 string
---@param cols integer
---@param rows integer
---@return string
function M.prepare_image(img_base64, cols, rows)
    local buf = repl.buf
    assert(buf and vim.api.nvim_buf_is_valid(buf), "[ipython] REPL buffer is unavailable")

    local image = placeholders.new(img_base64)
    local ok, text = pcall(image.text, image, cols, rows)
    if not ok then
        image:delete()
        error(text, 0)
    end

    if #images == 0 then
        vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
            group = group,
            buffer = buf,
            once = true,
            callback = delete_images,
        })
    end

    table.insert(images, image)
    return text
end

--------------------------------------------------------------------------------
-- Send
--------------------------------------------------------------------------------

---@param message string
local function normalize_python_message(message)
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

---@param terminal Terminal
---@param start_idx integer
---@param end_idx integer
local send_range = vim.schedule_wrap(function(terminal, start_idx, end_idx)
    if start_idx > end_idx then
        start_idx, end_idx = end_idx, start_idx
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_idx - 1, end_idx, false)
    local normalized = normalize_python_message(table.concat(lines, "\n"))
    terminal:send(utils.wrap_bracketed(normalized) .. "\n")
    terminal:scroll()
end)

function M.send_visual()
    local start_idx = vim.fn.line("v")
    local end_idx = vim.fn.line(".")
    send_range(repl, start_idx, end_idx)
    vim.api.nvim_input([[<C-\><C-N>]])
end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

function M.setup()
    if vim.fn.executable("uv") == 1 then
        pip = { "uv", "pip" }
        repl.cmd = vim.list_extend({ "uv", "run" }, args)
    end

    local complete = function(arglead)
        local items = { "open", "close", "toggle", "install" }
        return vim.tbl_filter(function(item)
            return vim.startswith(item, arglead)
        end, items)
    end

    vim.api.nvim_create_user_command("IPython", function(o)
        if o.args == "open" then
            M.open_repl()
        elseif o.args == "close" then
            M.close_repl()
        elseif o.args == "toggle" then
            M.toggle_repl()
        elseif o.args == "install" then
            M.install_packages()
        else
            error("[ipython] unknown command: " .. o.args, 0)
        end
    end, { nargs = 1, complete = complete })
end

return M
