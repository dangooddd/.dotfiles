---@class preview.Image
---@field png string
---@field scale? number

---@class preview.Entry: preview.Image
---@field key string

---@class preview.Request
---@field key string
---@field render fun(dir: string): preview.Image

local M = {}
local images = require("placeholders")

local rendering = false
local cache_size = 32
local debounce = 50
local scheduled

---@type preview.Entry[]
local cache = {}
---@type preview.Entry?
local displayed
---@type preview.Request?
local current
---@type integer?
local image

---@param data string
---@param offset integer
---@return integer
local function u32be(data, offset)
    local a, b, c, d = data:byte(offset, offset + 3)
    return ((a * 256 + b) * 256 + c) * 256 + d
end

function M.close()
    current, scheduled = nil, nil
    if image then images.del(image) end
    image, displayed = nil, nil
end

function M.clear()
    M.close()
    cache = {}
end

---@param key string
---@return preview.Entry?
local function cached(key)
    for _, entry in ipairs(cache) do
        if entry.key == key then
            return entry
        end
    end
end

---@param entry preview.Entry
local function draw(entry)
    local bottom = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 0 and 0 or 1)
    local tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and vim.fn.tabpagenr("$") > 1)
    local max_width = math.min(297, math.floor(vim.o.columns / 2) - 4)
    local max_height = math.min(297, bottom - (tabline and 1 or 0) - 2)

    if max_width < 2 or max_height < 3 then
        M.close()
        return
    end

    local scale = (1 / 12) * (entry.scale or 1)
    local cols = u32be(entry.png, 17) * scale
    local rows = u32be(entry.png, 21) * scale / 2.5
    local fit = math.min(1, max_width / cols, max_height / rows)
    local width = math.min(max_width, math.max(2, math.ceil(cols * fit)))
    local height = math.min(max_height, math.max(3, math.ceil(rows * fit)))
    local row = bottom - height - 2
    local col = vim.o.columns - width - 4
    local cursor = vim.api.nvim_win_get_cursor(0)
    local pos = vim.fn.screenpos(0, cursor[1], cursor[2] + 1)

    if
        pos.row > row and pos.row <= row + height + 2
        and pos.curscol > col and pos.curscol <= col + width + 4
    then
        M.close()
        return
    end

    local id = images.set(displayed == entry and image or entry.png, {
        row = row + 2,
        col = col + 3,
        width = width,
        height = height,
        border = vim.o.winborder,
        padding = { x = 1, y = 0 },
        zindex = 75,
    })

    if image and image ~= id then
        images.del(image)
    end

    image, displayed = id, entry
end

local function render_next()
    if rendering or not current or cached(current.key) then
        return
    end

    local request = current
    local entries = cache
    local dir = vim.fn.tempname()
    rendering = true

    vim.async.run(function()
        vim.fn.mkdir(dir, "p")
        return request.render(dir)
    end):on_complete(vim.schedule_wrap(function(err, entry)
        vim.fn.delete(dir, "rf")
        rendering = false

        if entries ~= cache then
            render_next()
            return
        end

        if not err then
            entry.key = request.key
            cache[#cache + 1] = entry
            if #cache > cache_size then
                table.remove(cache, 1)
            end
        end

        if not current then
            return
        end

        if current.key ~= request.key then
            render_next()
            return
        end

        if err then
            M.close()
            vim.notify("[preview] " .. tostring(err), vim.log.levels.ERROR)
            return
        end

        draw(entry)
    end))
end

---@param resolve fun(): preview.Request?
function M.schedule(resolve)
    local ticket = {}
    scheduled, current = ticket, nil

    vim.defer_fn(function()
        if scheduled ~= ticket then return end

        vim.async.run(resolve):on_complete(vim.schedule_wrap(function(err, request)
            if scheduled ~= ticket then
                return
            end

            if err or not request then
                M.close()
                if err then
                    vim.notify("[preview] " .. tostring(err), vim.log.levels.ERROR)
                end
                return
            end

            current = request
            local entry = cached(request.key)

            if entry then
                draw(entry)
            else
                render_next()
            end
        end))
    end, debounce)
end

local group = vim.api.nvim_create_augroup("Preview", { clear = true })

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "VimSuspend" }, {
    group = group,
    callback = M.close,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = M.clear,
})

vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
        if displayed then draw(displayed) end
    end,
})

return M
