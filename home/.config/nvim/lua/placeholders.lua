local M = {}

---@class PlaceholdersImage
local Image = {}
Image.__index = Image

local utils = require("utils")
local group = vim.api.nvim_create_augroup("Placeholders", { clear = true })
local ns = vim.api.nvim_create_namespace("Placeholders")
local next_id = 1
local max_ids = 255
local placeholder = "\u{10EEEE}"
local esc = "\x1b"

-- stylua: ignore start
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
-- stylua: ignore end

---@param path string
local function file_to_png_base64(path)
    local result = vim.system({
        "magick",
        path,
        "png:-",
    }, { text = false }):wait()

    if result.code ~= 0 then
        error("[placeholders] magic failed: " .. (result.stderr or "unknown error"))
    end

    return vim.base64.encode(result.stdout)
end

---@param body string
local function send_apc(body)
    local sequence = esc .. "_G" .. body .. esc .. "\\"

    if utils.detect_tmux() then
        sequence = utils.wrap_tmux(sequence)
    end

    vim.api.nvim_ui_send(sequence)
end

---@param img_id integer
---@param img_data string
local function upload_image(img_id, img_data)
    for offset = 1, #img_data, 4096 do
        local chunk = img_data:sub(offset, offset + 4095)
        local more = offset + 4096 <= #img_data and 1 or 0
        local header = offset == 1 and ("f=100,t=d,i=%d,q=2,"):format(img_id) or ""
        send_apc(("%sm=%d;%s"):format(header, more, chunk))
    end
end

---@param img_id integer
local function clear_image(img_id)
    send_apc(("a=d,d=i,i=%d,q=2"):format(img_id))
end

---@param img_id integer
local function delete_image(img_id)
    send_apc(("a=d,d=I,i=%d,q=2"):format(img_id))
end

---@param img_id integer
---@param cols integer
---@param rows integer
local function create_placement(img_id, cols, rows)
    send_apc(("a=p,U=1,i=%d,c=%d,r=%d,C=1,q=2"):format(img_id, cols, rows))
end

---@return integer
local function get_image_id()
    local id = next_id
    next_id = (next_id % max_ids) + 1
    return id
end

---@param cols integer
---@param rows integer
---@return string
function Image:text(cols, rows)
    assert(self.id, "[placeholders] image has been deleted")
    cols = math.max(1, math.min(math.floor(cols), #diac))
    rows = math.max(1, math.min(math.floor(rows), #diac))

    create_placement(self.id, cols, rows)

    local color = vim.o.termguicolors and ("%s[0m%s[38;2;0;0;%dm"):format(esc, esc, self.id)
        or ("%s[0m%s[38;5;%dm"):format(esc, esc, self.id)
    local lines = {}

    for r = 1, rows do
        local cells = {}
        for c = 1, cols do
            cells[c] = placeholder .. diac[r] .. diac[c]
        end
        lines[r] = "  " .. color .. table.concat(cells) .. esc .. "[0m"
    end

    return table.concat(lines, "\r\n") .. "\r\n"
end

---@param buf integer
---@param win integer
function Image:render(buf, win)
    if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) and self.id) then
        return
    end

    if not vim.bo[buf].modifiable then
        return
    end

    self:clear()
    self.buf = buf
    local rows = vim.api.nvim_win_get_height(win)
    local cols = vim.api.nvim_win_get_width(win)

    local hl = "PlaceholdersImage" .. self.id
    vim.api.nvim_set_hl(0, hl, { fg = self.id, ctermfg = self.id })

    local lines = {}
    for r = 1, rows do
        lines[#lines + 1] = placeholder .. diac[r] .. string.rep(placeholder, cols - 1)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.hl.range(buf, ns, hl, { 0, 0 }, { rows, #lines[#lines] }, {})

    vim.defer_fn(function()
        create_placement(self.id, cols, rows)
    end, 25)
end

function Image:clear()
    if self.id then
        clear_image(self.id)
        if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
            vim.api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)
        end
        self.buf = nil
    end
end

function Image:delete()
    if self.id then
        self:clear()
        delete_image(self.id)
        self.id = nil
    end
end

---@param img_base64 string
---@return PlaceholdersImage
function M.new(img_base64)
    vim.validate("img_base64", img_base64, "string")
    local image = setmetatable({}, Image)
    image.id = get_image_id()
    upload_image(image.id, img_base64)
    return image
end

---@param path string
function M.image_preview(path)
    vim.validate("path", path, "string")
    local result = file_to_png_base64(path)
    local image = M.new(result)

    local ratio = 0.8
    local width = vim.o.columns
    local height = vim.o.lines
    local float_width = math.max(1, math.floor(width * ratio))
    local float_height = math.max(1, math.floor(height * ratio))
    local col = math.max(0, math.floor((width - float_width - 2) / 2))
    local row = -float_height - 2

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, false, {
        relative = "laststatus",
        width = float_width,
        height = float_height,
        row = row,
        col = col,
        style = "minimal",
    })

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        group = group,
        callback = vim.schedule_wrap(function()
            image:delete()
            pcall(vim.api.nvim_win_close, win, false)
            vim.cmd.bdelete(buf)
        end),
    })

    vim.keymap.set("n", "q", "<Cmd>:q<CR>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<Cmd>:q<CR>", { buffer = buf, silent = true })
    vim.api.nvim_set_current_win(win)

    image:render(buf, win)
end

function M.setup()
    if vim.fn.executable("magick") ~= 1 then
        return
    end

    vim.api.nvim_create_user_command("Placeholders", function(o)
        if #o.args > 0 then
            M.image_preview(o.args)
        else
            M.image_preview(vim.api.nvim_buf_get_name(0))
        end
    end, { complete = "file", nargs = "?" })
end

return M
