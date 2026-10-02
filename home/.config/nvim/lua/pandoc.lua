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

---@param ctx render.md.handler.Context
---@return render.md.Mark[]
function M.parse(ctx)
    local marks = {}

    if not ctx.last then
        return marks
    end

    local opened
    local width = vim.api.nvim_win_get_width(0)
        - vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff

    for i, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
        local boundary

        if opened and line:match("^:::+%s*$") then
            opened = false
            boundary = "└" .. string.rep("─", width - 2) .. "┘"
        elseif line:match("^:::+") then
            local label = line:match("%.markdown") and " markdown " or line:match("%.code") and " code " or ""
            opened = true
            boundary = "┌" .. label .. string.rep("─", width - #label - 2) .. "┐"
        end

        if boundary then
            marks[#marks + 1] = {
                conceal = true,
                start_row = i - 1,
                start_col = 0,
                opts = {
                    end_col = #line,
                    conceal = "",
                    virt_text = { { boundary, "Comment" } },
                    virt_text_pos = "overlay",
                },
            }
        end
    end

    return marks
end

---@param buf integer
function M.import(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local output = vim.fn.fnamemodify(name, ":r") .. ".md"
    local source = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    local filter = vim.api.nvim_get_runtime_file("runtime/pandoc-import.lua", false)[1]
    local cmd = {
        "pandoc", "-", "--wrap=preserve", "-o", output,
        "-f", "ipynb+fancy_lists+tex_math_single_backslash",
        "-t", "markdown+fenced_divs-header_attributes-raw_attribute"
            .. "-smart-simple_tables-multiline_tables"
            .. "-grid_tables+pipe_tables",
        "--ipynb-output=none",
        "--lua-filter=" .. filter,
        "--extract-media=.pandoc/" .. vim.fn.fnamemodify(name, ":t:r"),
    }

    return vim.async.run(function()
        local result = vim.async.await(3, vim.system, cmd, {
            text = true,
            stdin = source == "" and template or source,
            cwd = vim.fn.fnamemodify(name, ":h"),
        })

        if result.code ~= 0 then
            error("[pandoc] " .. result.stderr, 0)
        end

        vim.async.await(vim.schedule)
        vim.cmd.edit(vim.fn.fnameescape(output))
    end)
end

---@param buf? integer
function M.export(buf)
    buf = buf or vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    local output = vim.fn.fnamemodify(name, ":r") .. ".ipynb"
    local source = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    local filter = vim.api.nvim_get_runtime_file("runtime/pandoc-export.lua", false)[1]
    local cmd = {
        "pandoc", "-", "--wrap=preserve", "-o", output,
        "-f", "markdown+fenced_divs-smart-implicit_figures",
        "-t", "ipynb",
        "--lua-filter=" .. filter,
    }

    return vim.async.run(function()
        local result = vim.async.await(3, vim.system, cmd, {
            text = true,
            stdin = source,
            cwd = vim.fn.fnamemodify(name, ":h"),
        })

        if result.code ~= 0 then
            error("[pandoc] " .. result.stderr, 0)
        end

        vim.async.await(vim.schedule)
        print(string.format("[pandoc] successfully exported `%s`", vim.fn.fnamemodify(output, ":t")))
    end)
end

function M.setup()
    local group = vim.api.nvim_create_augroup("Pandoc", { clear = true })

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
                vim.keymap.set("n", key, function()
                    M._repeat = function()
                        jump_cell(backward)
                    end
                    vim.go.operatorfunc = "v:lua.require'pandoc'._repeat"
                    return "g@l"
                end, { buffer = o.buf, expr = true })

                vim.keymap.set({ "x", "o" }, key, function()
                    jump_cell(backward)
                end, { buffer = o.buf })
            end
        end,
    })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = group,
        pattern = "*.ipynb",
        callback = vim.schedule_wrap(function(o)
            if vim.api.nvim_get_current_buf() == o.buf then
                M.import(o.buf)
            end
        end),
    })
end

return M
