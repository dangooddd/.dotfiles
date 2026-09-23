local M = {}

local images = {}
local ns = vim.api.nvim_create_namespace("Placeholders")
local next_id = (vim.fn.getpid() % 1024) * 16384
local tmux = false
local placeholder = "\u{10EEEE}"
local esc = "\x1b"

local diac = {
    "\u{0305}", "\u{030D}", "\u{030E}", "\u{0310}", "\u{0312}", "\u{033D}", "\u{033E}",
    "\u{033F}", "\u{0346}", "\u{034A}", "\u{034B}", "\u{034C}", "\u{0350}", "\u{0351}",
    "\u{0352}", "\u{0357}", "\u{035B}", "\u{0363}", "\u{0364}", "\u{0365}", "\u{0366}",
    "\u{0367}", "\u{0368}", "\u{0369}", "\u{036A}", "\u{036B}", "\u{036C}", "\u{036D}",
    "\u{036E}", "\u{036F}", "\u{0483}", "\u{0484}", "\u{0485}", "\u{0486}", "\u{0487}",
    "\u{0592}", "\u{0593}", "\u{0594}", "\u{0595}", "\u{0597}", "\u{0598}", "\u{0599}",
    "\u{059C}", "\u{059D}", "\u{059E}", "\u{059F}", "\u{05A0}", "\u{05A1}", "\u{05A8}",
    "\u{05A9}", "\u{05AB}", "\u{05AC}", "\u{05AF}", "\u{05C4}", "\u{0610}", "\u{0611}",
    "\u{0612}", "\u{0613}", "\u{0614}", "\u{0615}", "\u{0616}", "\u{0617}", "\u{0657}",
    "\u{0658}", "\u{0659}", "\u{065A}", "\u{065B}", "\u{065D}", "\u{065E}", "\u{06D6}",
    "\u{06D7}", "\u{06D8}", "\u{06D9}", "\u{06DA}", "\u{06DB}", "\u{06DC}", "\u{06DF}",
    "\u{06E0}", "\u{06E1}", "\u{06E2}", "\u{06E4}", "\u{06E7}", "\u{06E8}", "\u{06EB}",
    "\u{06EC}", "\u{0730}", "\u{0732}", "\u{0733}", "\u{0735}", "\u{0736}", "\u{073A}",
    "\u{073D}", "\u{073F}", "\u{0740}", "\u{0741}", "\u{0743}", "\u{0745}", "\u{0747}",
    "\u{0749}", "\u{074A}", "\u{07EB}", "\u{07EC}", "\u{07ED}", "\u{07EE}", "\u{07EF}",
    "\u{07F0}", "\u{07F1}", "\u{07F3}", "\u{0816}", "\u{0817}", "\u{0818}", "\u{0819}",
    "\u{081B}", "\u{081C}", "\u{081D}", "\u{081E}", "\u{081F}", "\u{0820}", "\u{0821}",
    "\u{0822}", "\u{0823}", "\u{0825}", "\u{0826}", "\u{0827}", "\u{0829}", "\u{082A}",
    "\u{082B}", "\u{082C}", "\u{082D}", "\u{0951}", "\u{0953}", "\u{0954}", "\u{0F82}",
    "\u{0F83}", "\u{0F86}", "\u{0F87}", "\u{135D}", "\u{135E}", "\u{135F}", "\u{17DD}",
    "\u{193A}", "\u{1A17}", "\u{1A75}", "\u{1A76}", "\u{1A77}", "\u{1A78}", "\u{1A79}",
    "\u{1A7A}", "\u{1A7B}", "\u{1A7C}", "\u{1B6B}", "\u{1B6D}", "\u{1B6E}", "\u{1B6F}",
    "\u{1B70}", "\u{1B71}", "\u{1B72}", "\u{1B73}", "\u{1CD0}", "\u{1CD1}", "\u{1CD2}",
    "\u{1CDA}", "\u{1CDB}", "\u{1CE0}", "\u{1DC0}", "\u{1DC1}", "\u{1DC3}", "\u{1DC4}",
    "\u{1DC5}", "\u{1DC6}", "\u{1DC7}", "\u{1DC8}", "\u{1DC9}", "\u{1DCB}", "\u{1DCC}",
    "\u{1DD1}", "\u{1DD2}", "\u{1DD3}", "\u{1DD4}", "\u{1DD5}", "\u{1DD6}", "\u{1DD7}",
    "\u{1DD8}", "\u{1DD9}", "\u{1DDA}", "\u{1DDB}", "\u{1DDC}", "\u{1DDD}", "\u{1DDE}",
    "\u{1DDF}", "\u{1DE0}", "\u{1DE1}", "\u{1DE2}", "\u{1DE3}", "\u{1DE4}", "\u{1DE5}",
    "\u{1DE6}", "\u{1DFE}", "\u{20D0}", "\u{20D1}", "\u{20D4}", "\u{20D5}", "\u{20D6}",
    "\u{20D7}", "\u{20DB}", "\u{20DC}", "\u{20E1}", "\u{20E7}", "\u{20E9}", "\u{20F0}",
    "\u{2CEF}", "\u{2CF0}", "\u{2CF1}", "\u{2DE0}", "\u{2DE1}", "\u{2DE2}", "\u{2DE3}",
    "\u{2DE4}", "\u{2DE5}", "\u{2DE6}", "\u{2DE7}", "\u{2DE8}", "\u{2DE9}", "\u{2DEA}",
    "\u{2DEB}", "\u{2DEC}", "\u{2DED}", "\u{2DEE}", "\u{2DEF}", "\u{2DF0}", "\u{2DF1}",
    "\u{2DF2}", "\u{2DF3}", "\u{2DF4}", "\u{2DF5}", "\u{2DF6}", "\u{2DF7}", "\u{2DF8}",
    "\u{2DF9}", "\u{2DFA}", "\u{2DFB}", "\u{2DFC}", "\u{2DFD}", "\u{2DFE}", "\u{2DFF}",
    "\u{A66F}", "\u{A67C}", "\u{A67D}", "\u{A6F0}", "\u{A6F1}", "\u{A8E0}", "\u{A8E1}",
    "\u{A8E2}", "\u{A8E3}", "\u{A8E4}", "\u{A8E5}", "\u{A8E6}", "\u{A8E7}", "\u{A8E8}",
    "\u{A8E9}", "\u{A8EA}", "\u{A8EB}", "\u{A8EC}", "\u{A8ED}", "\u{A8EE}", "\u{A8EF}",
    "\u{A8F0}", "\u{A8F1}", "\u{AAB0}", "\u{AAB2}", "\u{AAB3}", "\u{AAB7}", "\u{AAB8}",
    "\u{AABE}", "\u{AABF}", "\u{AAC1}", "\u{FE20}", "\u{FE21}", "\u{FE22}", "\u{FE23}",
    "\u{FE24}", "\u{FE25}", "\u{FE26}", "\u{10A0F}", "\u{10A38}", "\u{1D185}", "\u{1D186}",
    "\u{1D187}", "\u{1D188}", "\u{1D189}", "\u{1D1AA}", "\u{1D1AB}", "\u{1D1AC}", "\u{1D1AD}",
    "\u{1D242}", "\u{1D243}", "\u{1D244}",
}

local function wrap_apc(body)
    local data = esc .. "_G" .. body .. esc .. "\\"
    if tmux then
        data = require("utils").wrap_tmux(data)
    end
    return data
end

local function upload(id, png)
    local data = vim.base64.encode(png)
    local chunks = {}
    for pos = 1, #data, 4096 do
        local header = pos == 1 and string.format("a=t,f=100,t=d,i=%d,", id) or ""
        local more = pos + 4096 <= #data and 1 or 0
        local body = header .. string.format("q=2,m=%d;%s", more, data:sub(pos, pos + 4095))
        chunks[#chunks + 1] = wrap_apc(body)
    end
    vim.api.nvim_ui_send(table.concat(chunks))
end

function M.set(data_or_id, opts)
    opts = opts or {}
    vim.validate("data_or_id", data_or_id, { "string", "number" })
    vim.validate("opts", opts, "table")

    local image
    if type(data_or_id) == "number" then
        image = images[data_or_id]
        assert(image, "invalid image id: " .. tostring(data_or_id))
        opts = vim.tbl_extend("force", image.opts, opts)
        if image.win and vim.api.nvim_win_is_valid(image.win) and vim.deep_equal(opts, image.opts) then
            return image.id
        end
    else
        opts = vim.deepcopy(opts)
    end

    for _, name in ipairs({ "width", "height" }) do
        local value = opts[name]
        assert(type(value) == "number" and value % 1 == 0 and value >= 1 and value <= #diac,
            name .. " must be an integer between 1 and " .. #diac)
    end

    if not image then
        next_id = next_id + 1
        assert(next_id <= 0xFFFFFF, "image ids exhausted")
        image = { id = next_id, buf = vim.api.nvim_create_buf(false, true) }
        images[image.id] = image
        vim.bo[image.buf].undolevels = -1
        vim.api.nvim_set_hl(0, "PlaceholdersImage" .. image.id, { fg = image.id })
        upload(image.id, data_or_id)
    end

    if not image.opts or opts.width ~= image.opts.width or opts.height ~= image.opts.height then
        local lines = {}
        for row = 1, opts.height do
            local cells = {}
            for col = 1, opts.width do
                cells[col] = placeholder .. diac[row] .. diac[col]
            end
            lines[row] = table.concat(cells)
        end
        vim.api.nvim_buf_set_lines(image.buf, 0, -1, false, lines)
        vim.api.nvim_buf_clear_namespace(image.buf, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(image.buf, ns, 0, 0, {
            end_row = #lines,
            hl_group = "PlaceholdersImage" .. image.id,
        })
        local body = string.format("a=p,U=1,i=%d,p=1,c=%d,r=%d,q=2",
            image.id, opts.width, opts.height)
        vim.api.nvim_ui_send(wrap_apc(body))
    end

    local config = {
        relative = "editor",
        row = (opts.row or 1) - 1,
        col = (opts.col or 1) - 1,
        width = opts.width,
        height = opts.height,
        style = "minimal",
        border = "none",
        focusable = false,
        mouse = false,
        zindex = opts.zindex or 50,
    }
    if image.win and vim.api.nvim_win_is_valid(image.win) then
        vim.api.nvim_win_set_config(image.win, config)
    else
        config.noautocmd = true
        image.win = vim.api.nvim_open_win(image.buf, false, config)
        vim.wo[image.win].wrap = false
        vim.wo[image.win].winblend = 0
        vim.wo[image.win].winhighlight = "Normal:NormalFloat"
    end
    image.opts = opts
    return image.id
end

function M.get(id)
    vim.validate("id", id, "number")
    return images[id] and vim.deepcopy(images[id].opts) or nil
end

function M.del(id)
    vim.validate("id", id, "number")
    if id == math.huge then
        local found = next(images) ~= nil
        for key in pairs(images) do
            M.del(key)
        end
        return found
    end

    local image = images[id]
    if not image then
        return false
    end
    images[id] = nil
    if image.win and vim.api.nvim_win_is_valid(image.win) then
        vim.api.nvim_win_close(image.win, true)
    end
    if vim.api.nvim_buf_is_valid(image.buf) then
        vim.api.nvim_buf_delete(image.buf, { force = true })
    end
    vim.api.nvim_ui_send(wrap_apc(string.format("a=d,d=I,i=%d,q=2", id)))
    vim.api.nvim_set_hl(0, "PlaceholdersImage" .. id, {})
    return true
end

function M.setup()
    M.del(math.huge)
    tmux = require("utils").detect_tmux()
    vim.o.termguicolors = true
    vim.ui.img = M

    local group = vim.api.nvim_create_augroup("Placeholders", { clear = true })
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        callback = function()
            M.del(math.huge)
        end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function()
            for id in pairs(images) do
                vim.api.nvim_set_hl(0, "PlaceholdersImage" .. id, { fg = id })
            end
        end,
    })
end

return M
