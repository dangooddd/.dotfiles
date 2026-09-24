---@class markdown.Entry
---@field key string
---@field png string
---@field width integer
---@field height integer
---@field image? integer

---@class markdown.Target
---@field buf integer
---@field tick integer
---@field node TSNode
---@field key string
---@field source? string
---@field data? string
---@field formula? string
---@field fg? string
---@field max_width? integer
---@field max_height? integer

local M = {}
local images = require("placeholders")

local debounce = 50
local dpi = 576
local scale = 1.5
local cache_size = 32

local template = [[
\documentclass[border=1pt]{standalone}
\usepackage[T2A]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage[english,russian]{babel}
\usepackage{amsmath,amssymb,xcolor}
\definecolor{fg}{HTML}{%s}
\begin{document}\color{fg}
$\displaystyle %s$
\end{document}
]]

---@type markdown.Entry[]
local cache = {}
---@type markdown.Entry?
local displayed
---@type markdown.Target?
local current
---@type table?
local scheduled
local rendering

---@param data string
---@param offset integer
---@return integer
local function u32be(data, offset)
    local a, b, c, d = data:byte(offset, offset + 3)
    return ((a * 256 + b) * 256 + c) * 256 + d
end

function M.close()
    current, scheduled = nil, nil
    if displayed then
        images.del(displayed.image)
        displayed = nil
    end
end

local function clear()
    M.close()
    cache = {}
end

---@param key string
---@return markdown.Entry?
local function cached(key)
    for _, entry in ipairs(cache) do
        if entry.key == key then
            return entry
        end
    end
end

local function bottom()
    return vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
end

---@param entry markdown.Entry
local function show(entry)
    local width = entry.width + 2
    local row = bottom() - entry.height - 2
    local col = vim.o.columns - width - 2
    if row < 0 or col < 0 then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)

    if
        pos.row > row
        and pos.row <= row + entry.height + 2
        and pos.curscol > col
        and pos.curscol <= col + width + 2
    then
        M.close()
        return
    end

    if displayed == entry then
        return
    end

    entry.image = images.set(entry.image or entry.png, {
        row = row + 2,
        col = col + 3,
        width = entry.width,
        height = entry.height,
        border = "solid",
        padding = { x = 1, y = 0 },
        zindex = 75,
    })

    if displayed then
        images.del(displayed.image)
    end
    displayed = entry
end

---@param ticket table
---@return markdown.Target?
local function target_at_cursor(ticket)
    if vim.bo.filetype ~= "markdown" or vim.api.nvim_win_get_config(0).relative ~= "" then
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local tick = vim.api.nvim_buf_get_changedtick(buf)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    if
        current
        and current.buf == buf
        and current.tick == tick
        and vim.treesitter.is_in_node_range(current.node, row, col)
    then
        return current
    end

    local parser = vim.treesitter.get_parser(buf, "markdown")
    local err = vim.async.await(3, parser.parse, parser, { row, row + 1 })

    if
        scheduled ~= ticket
        or not vim.api.nvim_buf_is_valid(buf)
        or vim.api.nvim_buf_get_changedtick(buf) ~= tick
    then
        return
    end

    if err then
        error(err, 0)
    end

    local inline = parser:children().markdown_inline
    local node = inline and inline:named_node_for_range({ row, col, row, col })
    while node and node:type() ~= "image" and node:type() ~= "latex_block" do
        node = node:parent()
    end

    if not node then
        return
    end

    ---@type markdown.Target
    local target = { buf = buf, tick = tick, node = node }
    if node:type() == "image" then
        for child in node:iter_children() do
            if child:type() == "link_destination" then
                local source = vim.treesitter.get_node_text(child, buf)
                target.source = (source:match("^<(.*)>$") or source):gsub("\\(%p)", "%1")
                break
            end
        end

        if not target.source then
            return
        end

        if target.source:match("^data:image/") then
            target.data = target.source:match("^data:image/[^,]+;base64,(.+)$")
            if not target.data then
                error("Expected a base64 data:image URI", 0)
            end
            target.key = "image:" .. vim.fn.sha256(target.source)
        else
            if target.source:match("^%a[%w+.-]*:") then
                error("Image preview supports local files and base64 data:image URIs", 0)
            end

            local name = vim.api.nvim_buf_get_name(buf)
            local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
            target.source = vim.fs.normalize(vim.fs.abspath(vim.uri_decode(target.source), { cwd = dir }))
            target.key = "image:" .. target.source
        end
    else
        local first = node:child(0)
        local last = node:child(node:child_count() - 1)

        if
            not first
            or not last
            or first == last
            or first:type() ~= "latex_span_delimiter"
            or last:type() ~= "latex_span_delimiter"
        then
            return
        end

        local start_row, start_col = first:end_()
        local end_row, end_col = last:start()
        local lines = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
        target.formula = vim.trim(table.concat(lines, "\n"))

        if target.formula == "" then
            return
        end
        target.key = "formula:" .. target.formula
    end

    return target
end

---@param target markdown.Target
---@param dir string
---@return markdown.Entry?
local function render(target, dir)
    vim.fn.mkdir(dir, "p")
    local commands, stdin

    if target.source then
        local source = target.data and "-" or target.source
        stdin = target.data and vim.base64.decode((target.data:gsub("%s", "")))
        commands = {
            {
                "magick",
                source .. "[0]",
                "-auto-orient",
                "-strip",
                "PNG32:preview.png",
            },
        }
    else
        local document = string.format(template, target.fg, target.formula)
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
    end

    for _, cmd in ipairs(commands) do
        local result = vim.async.await(3, vim.system, cmd, {
            cwd = dir,
            text = true,
            timeout = 10000,
            stdin = stdin,
        })
        vim.async.await(vim.schedule)

        if current ~= target then
            return
        end

        if result.code ~= 0 then
            error(cmd[1] .. ": " .. (result.stdout or "") .. (result.stderr or ""), 0)
        end
    end

    local png = vim.fn.readblob(dir .. "/preview.png")
    local cell_width = target.formula and dpi / (12 * scale) or 12
    local cols = u32be(png, 17) / cell_width
    local rows = u32be(png, 21) / (2 * cell_width)
    local fit = math.min(1, target.max_width / cols, target.max_height / rows)

    return {
        key = target.key,
        png = png,
        width = math.min(target.max_width, math.max(2, math.ceil(cols * fit))),
        height = math.min(target.max_height, math.max(3, math.ceil(rows * fit))),
    }
end

local function render_next()
    if rendering or not current or cached(current.key) then
        return
    end

    local target = current
    local dir = vim.fn.tempname()
    rendering = vim.async.run(render, target, dir):detach()

    rendering:on_complete(vim.schedule_wrap(function(_, entry)
        rendering = nil
        vim.fn.delete(dir, "rf")

        if current ~= target then
            render_next()
            return
        end

        if entry then
            cache[#cache + 1] = entry
            if #cache > cache_size then
                table.remove(cache, cache[1] == displayed and 2 or 1)
            end
            if not scheduled then
                show(entry)
            end
        end
    end))
end

---@param ticket table
local function update(ticket)
    local target = target_at_cursor(ticket)
    if scheduled ~= ticket then
        return
    end

    if not target then
        M.close()
        return
    end

    local tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr("$") > 1)
    local editor_width = vim.o.columns
    local editor_height = bottom() - (tabline and 1 or 0) - 2
    local max_width = math.min(297, math.floor(editor_width / 2) - 4)
    local max_height = math.min(297, editor_height)

    if max_width < 2 or max_height < 2 then
        M.close()
        return
    end

    if current and current.key == target.key then
        current.buf, current.tick, current.node = target.buf, target.tick, target.node
    else
        local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
        target.fg = string.format("%06X", hl.fg or 0xD4DCC2)
        target.max_width, target.max_height = max_width, max_height
        current = target
        render_next()
    end

    local entry = cached(target.key)
    if entry then show(entry) end
    scheduled = nil
end

local function schedule()
    if vim.bo.filetype ~= "markdown" then
        M.close()
        return
    end

    local ticket = {}
    scheduled = ticket
    vim.defer_fn(function()
        if scheduled == ticket then
            vim.async.run(update, ticket):on_complete(vim.schedule_wrap(function(err)
                if err and scheduled == ticket then
                    current, scheduled = nil, nil
                end
            end))
        end
    end, debounce)
end

function M.setup()
    clear()
    local group = vim.api.nvim_create_augroup("MarkdownPreview", { clear = true })

    for _, executable in ipairs({ "latex", "dvipng", "magick" }) do
        if vim.fn.executable(executable) ~= 1 then
            return
        end
    end

    ---@param buf integer
    local function attach(buf)
        vim.api.nvim_clear_autocmds({ group = group, buffer = buf })
        vim.api.nvim_create_autocmd({
            "BufEnter",
            "WinEnter",
            "CursorMoved",
            "CursorMovedI",
            "TextChanged",
            "TextChangedI",
        }, {
            group = group,
            buffer = buf,
            callback = schedule,
        })

        vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
            group = group,
            buffer = buf,
            callback = M.close,
        })

        vim.api.nvim_create_autocmd("BufFilePost", {
            group = group,
            buffer = buf,
            callback = function()
                clear()
                schedule()
            end,
        })
    end

    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "markdown",
        callback = function(event)
            attach(event.buf)
            schedule()
        end,
    })

    vim.api.nvim_create_autocmd("VimSuspend", {
        group = group,
        callback = M.close,
    })

    vim.api.nvim_create_autocmd({ "VimResized", "ColorScheme", "VimResume" }, {
        group = group,
        callback = function()
            clear()
            schedule()
        end,
    })

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == "markdown" then
            attach(buf)
        end
    end
    schedule()
end

return M
