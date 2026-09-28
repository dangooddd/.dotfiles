local M = {}

local timeout_ms = 200
local tmux_detected = nil
local container_detected = nil
local esc = "\x1b"

---@param sequence string
---@return string
function M.wrap_tmux(sequence)
    return esc .. "Ptmux;" .. sequence:gsub(esc, esc .. esc) .. esc .. "\\"
end

---@param text string
---@return string
function M.wrap_bracketed(text)
    return esc .. "[200~" .. text .. esc .. "[201~"
end

---@return boolean
function M.detect_tmux()
    if tmux_detected ~= nil then
        return tmux_detected
    end

    if vim.env.TMUX or vim.env.TERM == "tmux-256color" then
        tmux_detected = true
        return tmux_detected
    end

    vim.tty.request(M.wrap_tmux(esc .. "[c"), {
        timeout = timeout_ms,
        on_timeout = function() tmux_detected = false end,
    }, function(sequence)
        if sequence:match("^" .. esc .. "%[%?[%d;]*c$") then
            tmux_detected = true
            return true
        end
    end)

    vim.wait(timeout_ms + 50, function()
        return tmux_detected ~= nil
    end, 5)

    return tmux_detected == true
end

---@return boolean
function M.detect_container()
    if container_detected ~= nil then
        return container_detected
    end

    if vim.uv.fs_stat("/.dockerenv") or vim.uv.fs_stat("/run/.containerenv") then
        container_detected = true
    else
        container_detected = false
    end

    return container_detected
end


---@param lines string[]
---@param cursor integer
function M.insert(lines, cursor)
    local buf = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + cursor, 0 })
end

return M
