---@class markdown.Target
---@field key string
---@field source? string
---@field data? string
---@field formula? string
---@field fg? string

local M = {}
local preview = require("preview")

local enabled = true
local dpi = 576
local scale = 1.5

local template = [[
\documentclass{article}
\pagestyle{empty}
\usepackage[T2A]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[english,russian]{babel}
\usepackage{amsmath,amssymb,xcolor}
\definecolor{fg}{HTML}{%s}
\begin{document}\color{fg}
%s
\end{document}
]]

local display = {
    align = true,
    alignat = true,
    flalign = true,
    gather = true,
    multline = true,
    equation = true,
    displaymath = true,
}

---@return markdown.Target?
local function resolve()
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    local parser = vim.treesitter.get_parser(buf, "markdown")
    local err = vim.async.await(3, parser.parse, parser, { row, row + 1 })
    if err then error(err, 0) end

    local inline = parser:children().markdown_inline
    local node = inline and inline:named_node_for_range({ row, col, row, col })
    while node and node:type() ~= "image" and node:type() ~= "latex_block" do
        node = node:parent()
    end
    if not node then return end

    if node:type() == "image" then
        if vim.fn.executable("magick") ~= 1 then
            return
        end

        local source
        for child in node:iter_children() do
            if child:type() == "link_destination" then
                source = vim.treesitter.get_node_text(child, buf)
                source = (source:match("^<(.*)>$") or source):gsub("\\(%p)", "%1")
                break
            end
        end

        if not source then
            return
        end

        if source:match("^data:image/") then
            local data = source:match("^data:image/[^,]+;base64,(.+)$")
            if not data then
                error("expected a base64 data:image URI", 0)
            end
            return { key = "image:" .. vim.fn.sha256(source), data = data }
        end

        if source:match("^%a[%w+.-]*:") then
            error("image preview supports local files and base64 data:image URIs", 0)
        end

        local name = vim.api.nvim_buf_get_name(buf)
        local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
        source = vim.fs.normalize(vim.fs.abspath(vim.uri_decode(source), { cwd = dir }))
        local stat = vim.uv.fs_stat(source)

        if not stat then
            return
        end

        local key = string.format("image:%s:%s:%s:%s", source, stat.size, stat.mtime.sec, stat.mtime.nsec)
        return { key = key, source = source }
    end

    if vim.fn.executable("latex") ~= 1 or vim.fn.executable("dvipng") ~= 1 then
        return
    end

    local first = node:child(0)
    local last = node:child(node:child_count() - 1)

    if
        not first or not last or first == last
        or first:type() ~= "latex_span_delimiter"
        or last:type() ~= "latex_span_delimiter"
    then
        return
    end

    local start_row, start_col = first:end_()
    local end_row, end_col = last:start()
    local lines = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
    local formula = vim.trim(table.concat(lines, "\n"))

    if formula == "" then
        return
    end

    local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
    local fg = string.format("%06X", hl.fg)
    return { key = "formula:" .. fg .. ":" .. formula, formula = formula, fg = fg }
end

---@param target markdown.Target
---@param dir string
---@return preview.Image
local function render(target, dir)
    local commands, stdin
    if target.formula then
        local formula = target.formula
        local env = formula:match("^\\begin%s*{([%a]+)%*?}")
        if not (env and display[env]) then
            formula = "$\\displaystyle " .. formula .. "$"
        end

        local document = string.format(template, target.fg, formula)
        vim.fn.writefile(vim.split(document, "\n", { plain = true }), dir .. "/formula.tex")
        commands = {
            {
                "latex",
                "-interaction=nonstopmode",
                "-halt-on-error",
                "-no-shell-escape",
                "formula.tex",
            },
            {
                "dvipng",
                "-q",
                "-T", "tight",
                "-D", tostring(dpi),
                "-bg", "Transparent",
                "-o", "preview.png",
                "formula.dvi",
            },
        }
    else
        local source = target.data and "-" or target.source
        stdin = target.data and vim.base64.decode((target.data:gsub("%s", "")))
        commands = {
            {
                "magick",
                source .. "[0]",
                "-auto-orient",
                "-strip",
                "PNG32:preview.png"
            },
        }
    end

    for _, cmd in ipairs(commands) do
        local result = vim.async.await(3, vim.system, cmd, {
            cwd = dir,
            text = true,
            timeout = 10000,
            stdin = stdin,
        })
        vim.async.await(vim.schedule)
        if result.code ~= 0 then
            error(cmd[1] .. ": " .. (result.stdout or "") .. (result.stderr or ""), 0)
        end
    end

    return {
        png = vim.fn.readblob(dir .. "/preview.png"),
        scale = target.formula and 144 * scale / dpi or 1,
    }
end

function M.close()
    preview.close()
end

local function update()
    if not enabled or vim.bo.filetype ~= "markdown" or vim.api.nvim_win_get_config(0).relative ~= "" then
        M.close()
        return
    end

    preview.schedule(function()
        local target = resolve()
        if not target then return end

        return {
            key = target.key,
            render = function(dir)
                return render(target, dir)
            end,
        }
    end)
end

function M.enable()
    enabled = true
    update()
end

function M.disable()
    enabled = false
    M.close()
end

function M.setup()
    M.close()
    local group = vim.api.nvim_create_augroup("MarkdownPreview", { clear = true })

    ---@param buf integer
    local function attach(buf)
        vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
        vim.api.nvim_create_autocmd({
            "BufEnter", "WinEnter", "CursorMoved", "CursorMovedI",
            "TextChanged", "TextChangedI", "TextChangedP", "BufFilePost",
        }, {
            group = group,
            buffer = buf,
            callback = update,
        })
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "markdown",
        callback = function(o)
            attach(o.buf)
            update()
        end,
    })

    vim.api.nvim_create_autocmd({ "ColorScheme", "VimResume" }, {
        group = group,
        callback = update,
    })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "markdown" then
            attach(buf)
        end
    end
    update()
end

return M
