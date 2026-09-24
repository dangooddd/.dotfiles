local M = {}

local pattern = [[^```\+\s*python\>]]
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

---@param inner boolean
local function select_cell(inner)
    local first = vim.fn.search(pattern, "bcnW")

    if vim.fn.mode():match("[vV\022]") then
        vim.cmd.normal({ vim.keycode([[<C-\><C-N>]]), bang = true })
    end

    if first == 0 then
        return
    end

    local fence = vim.fn.getline(first):match("^(`+)")
    local last = vim.fn.search([[^]] .. fence .. [[\s*$]], "nW")
    first = first + (inner and 1 or 0)
    last = last == 0 and vim.fn.line("$") or last - (inner and 1 or 0)
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

local function transform_notebook(buf)
    local markdown = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":r") .. ".md"

    vim.async.run(function()
        if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == "" then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(vim.trim(template), "\n"))
        end

        vim.async.await(M.sync())
        local script = vim.api.nvim_get_runtime_file("runtime/jupytext.py", false)[1]
        vim.async.await(3, vim.system, { "python3", script, markdown }, { text = true })
        vim.async.await(vim.schedule)
        vim.cmd.edit(vim.fn.fnameescape(markdown))
    end)
end

function M.sync()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)

    return vim.async.run(function()
        vim.api.nvim_buf_call(buf, function()
            vim.cmd.update()
        end)

        local result = vim.async.await(3, vim.system, { "jupytext", "--sync", name }, { text = true })
        if result.code ~= 0 then
            error("[jupytext] " .. (result.stderr or "sync failed"), 0)
        end
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("Jupytext", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "markdown",
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

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = group,
        pattern = "*.ipynb",
        callback = function(o)
            vim.schedule(function()
                transform_notebook(o.buf)
            end)
        end,
    })
end

return M
