local M = {}

local debounce = 50
local dpi = 576
local scale = 1.5
local cache_size = 64

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

local cache, order = {}, {}
local pending
local scheduled
local running = false
local win, buf, image, displayed

function M.close()
    pending = nil
    scheduled = nil

    if image then
        vim.ui.img.del(image)
    end
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
    end

    win, buf, image, displayed = nil, nil, nil, nil
end

local function target_at_cursor()
    if vim.bo.filetype ~= "markdown" or vim.api.nvim_win_get_config(0).relative ~= "" then
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1
    local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
    if not ok then
        M.last_error = tostring(parser)
        return
    end

    parser:parse({ row, row + 1 })
    local inline = parser:children().markdown_inline
    local node = inline and inline:named_node_for_range({ row, col, row, col })
    while node and node:type() ~= "image" and node:type() ~= "latex_block" do
        node = node:parent()
    end
    if not node then
        return
    end

    if node:type() == "image" then
        for child in node:iter_children() do
            if child:type() == "link_destination" then
                local source = vim.treesitter.get_node_text(child, 0)
                source = (source:match("^<(.*)>$") or source):gsub("\\(%p)", "%1")
                return { source = source }
            end
        end
        return
    end

    local first, last
    for child in node:iter_children() do
        if child:type() == "latex_span_delimiter" then
            if not first then
                first = child
            end
            last = child
        end
    end
    if first and last and first ~= last then
        local start_row, start_col = first:end_()
        local end_row, end_col = last:start()
        local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
        local formula = vim.trim(table.concat(lines, "\n"))
        if formula ~= "" then
            return { formula = formula }
        end
    end
end

local function resolve_source(target)
    if target.formula then
        return "formula:" .. target.formula
    end

    local source = target.source
    if source:match("^data:image/") then
        target.data = source:match("^data:image/[^,]+;base64,(.+)$")
        if not target.data then
            return nil, "Expected a base64 data:image URI"
        end
        return "image:" .. vim.fn.sha256(source)
    end
    if source:match("^%a[%w+.-]*:") then
        return nil, "Image preview supports local files and base64 data:image URIs"
    end

    local name = vim.api.nvim_buf_get_name(0)
    local dir = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
    target.source = vim.fs.normalize(vim.fs.abspath(vim.uri_decode(source), { cwd = dir }))
    local stat = vim.uv.fs_stat(target.source)
    if not stat or stat.type ~= "file" then
        return nil, "Image not found: " .. target.source
    end
    return table.concat({ "image", target.source, stat.size, stat.mtime.sec, stat.mtime.nsec }, ":")
end

local function bottom()
    return vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
end

local function show(entry)
    local width = entry.width + 2
    local row = bottom() - entry.height - 2
    local col = vim.o.columns - width - 2
    if row < 0 or col < 0 then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)
    if pos.row > row and pos.row <= row + entry.height + 2
        and pos.curscol > col and pos.curscol <= col + width + 2 then
        M.close()
        return
    end
    if displayed == entry then
        return
    end

    local opts = {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = entry.height,
        style = "minimal",
        border = "solid",
        focusable = false,
        mouse = false,
        zindex = 50,
        noautocmd = true,
    }
    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_config(win, opts)
    else
        buf = vim.api.nvim_create_buf(false, true)
        win = vim.api.nvim_open_win(buf, false, opts)
        vim.wo[win].winblend = 0
        vim.wo[win].winhighlight = "FloatBorder:NormalFloat"
    end

    local position = {
        row = row + 2,
        col = col + 3,
        width = entry.width,
        height = entry.height,
        zindex = 75,
    }
    local previous = image
    image = vim.ui.img.set(entry.png, position)
    if previous then
        vim.ui.img.del(previous)
    end
    displayed = entry
end

local function render(request, dir)
    local function run(cmd, stdin)
        local result = vim.async.await(3, vim.system, cmd, {
            cwd = dir,
            text = true,
            timeout = 10000,
            stdin = stdin,
        })
        vim.async.await(vim.schedule)
        if pending ~= request then
            error("Preview changed", 0)
        end
        if result.code ~= 0 then
            error(cmd[1] .. ": " .. (result.stdout or "") .. (result.stderr or ""), 0)
        end
    end

    if request.source then
        local source = request.data and "-" or request.source
        local data = request.data and vim.base64.decode((request.data:gsub("%s", "")))
        run({ "magick", source .. "[0]", "-auto-orient", "-strip", "PNG32:raw.png" }, data)
    else
        local document = string.format(template, request.fg, request.formula)
        vim.fn.writefile(vim.split(document, "\n", { plain = true }), dir .. "/formula.tex")
        run({
            "latex",
            "-interaction=nonstopmode",
            "-halt-on-error",
            "-no-shell-escape",
            "formula.tex",
        })

        run({
            "dvipng",
            "-q",
            "-T", "tight",
            "-D", tostring(dpi),
            "-bg", "Transparent",
            "-o", "raw.png",
            "formula.dvi",
        })
    end

    local png = vim.fn.readblob(dir .. "/raw.png", 0, 24)
    local function u32(offset)
        local a, b, c, d = png:byte(offset, offset + 3)
        return ((a * 256 + b) * 256 + c) * 256 + d
    end

    local width, height = u32(17), u32(21)
    local cell_w, cell_h = dpi / 12, dpi / 6
    local padding = math.ceil(dpi / 72)
    local max_scale = request.formula and scale or dpi / 144
    local scale = math.min(
        max_scale,
        (request.max_width * cell_w - 2 * padding) / width,
        (request.max_height * cell_h - 2 * padding) / height
    )
    local cols = math.ceil((width * scale + 2 * padding) / cell_w)
    local rows = math.ceil((height * scale + 2 * padding) / cell_h)
    local entry = {
        width = math.min(request.max_width, math.max(2, cols)),
        height = math.min(request.max_height, math.max(3, rows)),
    }
    local size = string.format(
        "%dx%d",
        math.max(1, math.floor(width * scale)),
        math.max(1, math.floor(height * scale))
    )
    local extent = string.format(
        "%dx%d",
        math.floor(entry.width * cell_w),
        math.floor(entry.height * cell_h)
    )
    run({
        "magick",
        "raw.png",
        "-filter", "Lanczos",
        "-resize", size,
        "-background", "none",
        "-gravity", "Center",
        "-extent", extent,
        "preview.png",
    })
    entry.png = vim.fn.readblob(dir .. "/preview.png")
    return entry
end

local function render_next()
    if running or not pending or not pending.ready then
        return
    end

    local request = pending
    local dir = vim.fn.tempname()
    request.ready = false
    running = true

    vim.async.run(function()
        vim.fn.mkdir(dir, "p")
        return render(request, dir)
    end):on_complete(vim.schedule_wrap(function(err, entry)
        vim.fn.delete(dir, "rf")
        running = false
        if pending == request then
            M.last_error = err and tostring(err) or nil
            if entry then
                cache[request.key] = entry
                order[#order + 1] = request.key
                if #order > cache_size then
                    cache[table.remove(order, 1)] = nil
                end
                if not scheduled then
                    show(entry)
                end
            end
        end
        render_next()
    end))
end

local function update()
    local target = target_at_cursor()
    if not target then
        M.close()
        return
    end

    local identity, err = resolve_source(target)
    if not identity then
        pending = nil
        M.last_error = err
        return
    end

    local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat", link = false })
    local tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr("$") > 1)
    local editor_height = bottom() - (tabline and 1 or 0)
    local request = {
        formula = target.formula,
        source = target.source,
        data = target.data,
        fg = string.format("%06X", hl.fg or 0xD4DCC2),
        max_width = math.floor(vim.o.columns / 2) - 4,
        max_height = math.floor(editor_height / 2) - 2,
    }
    if request.max_width < 2 or request.max_height < 2 then
        M.close()
        return
    end
    request.key = table.concat({
        identity,
        request.fg,
        request.max_width,
        request.max_height,
    }, "\n")
    if pending and pending.key == request.key then
        local entry = cache[request.key]
        if entry then
            show(entry)
        end
        return
    end

    pending = request
    M.last_error = nil
    if cache[request.key] then
        show(cache[request.key])
        return
    end

    request.ready = true
    render_next()
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
            scheduled = nil
            update()
        end
    end, debounce)
end

function M.setup()
    M.close()
    cache, order = {}, {}

    local group = vim.api.nvim_create_augroup("MarkdownPreview", { clear = true })
    for _, executable in ipairs({ "latex", "dvipng", "magick" }) do
        if vim.fn.executable(executable) ~= 1 then
            M.last_error = "executable not found: " .. executable
            return
        end
    end
    M.last_error = nil

    vim.api.nvim_create_autocmd({
        "FileType",
        "BufEnter",
        "WinEnter",
        "CursorMoved",
        "CursorMovedI",
        "TextChanged",
        "TextChangedI",
    }, {
        group = group,
        callback = schedule,
    })
    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "VimLeavePre", "VimSuspend" }, {
        group = group,
        callback = M.close,
    })
    vim.api.nvim_create_autocmd({ "VimResized", "ColorScheme", "VimResume" }, {
        group = group,
        callback = function()
            M.close()
            schedule()
        end,
    })

    schedule()
end

return M
