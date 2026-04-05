local M = {}

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

---@param path string
local function edit_relative(path)
    local relative = vim.fn.fnamemodify(path, ":.")
    vim.cmd.edit(vim.fn.fnameescape(relative))
end

---@param buf integer
local function get_buf_text(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    return table.concat(lines, "\n")
end

---@param buf integer
---@param ext string
local function bufname_with_ext(buf, ext)
    local name = vim.api.nvim_buf_get_name(buf)
    return vim.fn.fnamemodify(name, ":r") .. "." .. ext
end

---@param text string
---@param name string
---@param notebook boolean
local function convert_from_text(text, name, notebook)
    if name == "" then
        error("[jupytext] notebook name cannot be empty", 0)
    end

    if vim.fn.executable("jupytext") ~= 1 then
        error("[jupytext] executable not found", 0)
    end

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

function M.convert_to_python()
    local name = bufname_with_ext(0, "py")
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
            convert_from_text(text, name, false)
        end

        edit_relative(name)
    end)
end

function M.export_to_notebook()
    local name = bufname_with_ext(0, "ipynb")
    local text = get_buf_text(0)

    vim.schedule(function()
        convert_from_text(text, name, true)
        print(string.format('[jupytext] script exported to "%s"', name))
    end)
end

function M.setup()
    if vim.fn.executable("jupytext") ~= 1 then
        return
    end

    local complete = function(arglead)
        local items = { "convert", "export" }
        return vim.tbl_filter(function(item)
            return vim.startswith(item, arglead)
        end, items)
    end

    vim.api.nvim_create_user_command("Jupytext", function(o)
        if o.args == "convert" then
            M.convert_to_python()
        elseif o.args == "export" then
            M.export_to_notebook()
        else
            error("[jupytext] unknown command: " .. o.args, 0)
        end
    end, { complete = complete, nargs = 1 })

    local group = vim.api.nvim_create_augroup("Jupytext", { clear = true })
    vim.api.nvim_create_autocmd("BufReadPost", {
        group = group,
        pattern = "*.ipynb",
        callback = vim.schedule_wrap(M.convert_to_python),
    })
end

return M
