local M = {}

local pattern = [[^\s*#\s*%%]]
local template = [[
{
  "cells": [
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {},
      "outputs": [],
      "source": []
    }
  ],
  "metadata": {
    "language_info": { "name": "python" }
  },
  "nbformat": 4,
  "nbformat_minor": 5
}
]]

---@param buf integer
local function get_buf_text(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    return table.concat(lines, "\n")
end

---@param buf integer
---@param ext string
local function get_bufname_with_ext(buf, ext)
    local name = vim.api.nvim_buf_get_name(buf)
    return vim.fn.fnamemodify(name, ":r") .. "." .. ext
end

---@param inner boolean
local function select_cell(inner)
    local first = vim.fn.search(pattern, "bcnW")
    local last = vim.fn.search(pattern, "nW")

    if vim.fn.mode():match("[vV\022]") then
        vim.cmd.normal({ vim.keycode([[<C-\><C-N>]]), bang = true })
    end

    if first == 0 then
        return
    end

    first = first + (inner and 1 or 0)
    last = last == 0 and vim.fn.line("$") or last - 1
    if first > last then
        return
    end

    vim.cmd.normal({ string.format("%dGV%dG", first, last), bang = true })
end

---@param backward boolean
local function jump_cell(backward)
    local flags = backward and "bW" or "W"
    for _ = 1, vim.v.count1 do
        if vim.fn.search(pattern, flags) == 0 then
            break
        end
    end
end

---@param text string
---@param name string
---@param notebook boolean
local function transform_text(text, name, notebook)
    assert(name ~= "", "[jupytext] notebook name cannot be empty")
    assert(vim.fn.executable("jupytext") == 1, "[jupytext] executable not found")

    local cmd = { "jupytext", "--output", name }
    local format = "py:percent"

    if notebook then
        vim.list_extend(cmd, { "--update", "--from", format, "--to", "ipynb", "-" })
    else
        vim.list_extend(cmd, { "--to", format, "-" })
    end

    local result = vim.system(cmd, { text = true, stdin = text }):wait()
    if result.code ~= 0 then
        error("[jupytext] failed to convert text: " .. (result.stderr or "unknown error"), 0)
    end
end

function M.transform_notebook()
    local name = get_bufname_with_ext(0, "py")
    local stat = vim.uv.fs_stat(name)
    local choices = { "convert" }

    if stat and stat.type == "file" then
        choices[#choices + 1] = "open existing file"
    end

    vim.ui.select(choices, {
        prompt = string.format('Convert notebook to "%s"?', name),
    }, function(_, idx)
        if idx == nil then
            return
        end

        if idx == 1 then
            local text = get_buf_text(0)
            if #text == 0 then
                text = template
            end
            transform_text(text, name, false)
        end

        local relative = vim.fn.fnamemodify(name, ":.")
        vim.cmd.edit(vim.fn.fnameescape(relative))
    end)
end

function M.transform_python()
    local name = get_bufname_with_ext(0, "ipynb")
    local text = get_buf_text(0)

    vim.schedule(function()
        transform_text(text, name, true)
        print(string.format('[jupytext] script exported to "%s"', name))
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("Jupytext", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "python",
        callback = function(o)
            for key, inner in pairs({ ij = true, aj = false }) do
                vim.keymap.set({ "o", "x" }, key, function()
                    select_cell(inner)
                end, { buffer = o.buf })
            end

            for key, backward in pairs({ ["]j"] = false, ["[j"] = true }) do
                vim.keymap.set({ "n", "x", "o" }, key, function()
                    jump_cell(backward)
                end, { buffer = o.buf })
            end
        end,
    })

    if vim.fn.executable("jupytext") == 1 then
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = group,
            pattern = "*.ipynb",
            callback = vim.schedule_wrap(M.transform_notebook),
        })
    end
end

return M
