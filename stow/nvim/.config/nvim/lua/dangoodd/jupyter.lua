if vim.fn.executable("jupytext") ~= 1 then
    return
end

local group = vim.api.nvim_create_augroup("JupytextIpynb", { clear = true })
local generated_py = {}
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

local function run(cmd)
    local res = vim.system(cmd, { text = true }):wait()

    if res.code ~= 0 then
        vim.notify(res.stderr or table.concat(cmd, " "), vim.log.levels.ERROR)
        return false
    end

    return true
end

local function open_ipynb(buf)
    local ipynb = vim.api.nvim_buf_get_name(buf)
    local st = vim.uv.fs_stat(ipynb)
    local py = vim.fn.fnamemodify(ipynb, ":r") .. ".py"
    local existed_before = vim.uv.fs_stat(py) ~= nil

    if st == nil or st.size == 0 then
        local ok, err = pcall(vim.fn.writefile, vim.split(template, "\n", { plain = true }), ipynb)

        if not ok then
            vim.notify("failed to create notebook template: " .. tostring(err), vim.log.levels.ERROR)
            return false
        end
    end

    -- create and sync .py file
    if not run({ "jupytext", "--set-formats", "ipynb,py:percent", ipynb }) then return end
    if not run({ "jupytext", "--sync", ipynb }) then return end

    -- open .py instead of .ipynb
    vim.cmd("keepalt keepjumps edit " .. vim.fn.fnameescape(py))
    local py_buf = vim.api.nvim_get_current_buf()

    -- set filetype
    vim.bo[py_buf].filetype = "python"
    vim.api.nvim_exec_autocmds("FileType", { buffer = py_buf })

    -- metadata
    vim.b[py_buf].jupytext_ipynb = ipynb
    vim.b[py_buf].jupytext_py = py
    vim.b[py_buf].jupytext_managed = true

    if not existed_before then
        generated_py[py] = true
    end

    -- delete .ipynb buffer
    if buf ~= py_buf then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
end

local function sync_ipynb(buf)
    local old_py = vim.b[buf].jupytext_py
    local new_py = vim.api.nvim_buf_get_name(buf)

    if old_py ~= new_py then
        local old_ipynb = vim.b[buf].jupytext_ipynb
        local new_ipynb = vim.fn.fnamemodify(new_py, ":r") .. ".ipynb"

        if vim.uv.fs_stat(old_ipynb) then
            local ok, err = vim.uv.fs_rename(old_ipynb, new_ipynb)
            if not ok then
                vim.notify(
                    "failed to rename notebook files: " .. tostring(err),
                    vim.log.levels.ERROR
                )
                return
            end
        end

        vim.b[buf].jupytext_py = new_py
        vim.b[buf].jupytext_ipynb = new_ipynb
        generated_py[new_py] = true
    end

    run({ "jupytext", "--sync", vim.b[buf].jupytext_py })
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    pattern = "*.ipynb",
    callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        if vim.b[args.buf].jupytext_managed then return end
        vim.schedule(function() open_ipynb(args.buf) end)
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.py",
    callback = function(args)
        if not vim.api.nvim_buf_is_valid(args.buf) then return end
        if vim.b[args.buf].jupytext_managed ~= true then return end
        vim.defer_fn(function() sync_ipynb(args.buf) end, 250)
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
        for path in pairs(generated_py) do
            pcall(function()
                if vim.uv.fs_stat(path) then
                    vim.uv.fs_unlink(path)
                end
            end)
        end
    end,
})
