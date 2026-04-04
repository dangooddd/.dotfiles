local M = {}

local timeout_ms = 200
local tmux_detected = nil
local esc = "\x1b"

---Wrap an escape sequence so tmux passes it through to the terminal.
---@param sequence string
---@return string
function M.wrap_tmux(sequence)
    return esc .. "Ptmux;" .. sequence:gsub(esc, esc .. esc) .. esc .. "\\"
end

---Detect tmux by sending DA1.
---@return boolean
function M.detect_tmux()
    if tmux_detected ~= nil then
        return tmux_detected
    end

    if vim.env.TMUX or vim.env.TERM == "tmux-256color" then
        tmux_detected = true
        return tmux_detected
    end

    local autocmd
    autocmd = vim.api.nvim_create_autocmd("TermResponse", {
        callback = function(args)
            local sequence = args.data.sequence

            if type(sequence) ~= "string" then
                return
            end

            if sequence:find(esc .. "%[%?[%d;]*c") then
                tmux_detected = true
                pcall(vim.api.nvim_del_autocmd, autocmd)
            end
        end,
    })

    vim.api.nvim_ui_send(M.wrap_tmux(esc .. "[c"))

    vim.wait(timeout_ms, function()
        return tmux_detected or false
    end, 5)
    pcall(vim.api.nvim_del_autocmd, autocmd)

    if not tmux_detected then
        tmux_detected = false
    end

    return tmux_detected
end

return M
