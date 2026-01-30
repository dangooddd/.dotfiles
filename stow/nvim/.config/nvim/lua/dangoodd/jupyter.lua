if vim.fn.executable("jupytext") ~= 1 then
    return
end

local group = vim.api.nvim_create_augroup("Jupyter", { clear = true })

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

local function convert_py()
    run({ "jupytext", "--to", "ipynb", vim.api.nvim_buf_get_name(0) })
end

local function open_ipynb(buf)
    local ipynb = vim.api.nvim_buf_get_name(buf)
    local st = vim.uv.fs_stat(ipynb)
    local py = vim.fn.fnamemodify(ipynb, ":r") .. ".py"

    -- put template if notebook is empty
    if st == nil or st.size == 0 then
        local ok, err = pcall(vim.fn.writefile, vim.split(template, "\n", { plain = true }), ipynb)

        if not ok then
            vim.notify("failed to create notebook template: " .. tostring(err), vim.log.levels.ERROR)
            return false
        end
    end

    -- create python file from notebook and open it
    if not run({ "jupytext", "--to", "py:percent", vim.api.nvim_buf_get_name(0) }) then return end
    vim.cmd("keepalt keepjumps edit " .. vim.fn.fnameescape(py))
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
        vim.api.nvim_buf_create_user_command(args.buf, "JupyterSync", convert_py, {})
    end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    pattern = "*.ipynb",
    callback = function(args)
        vim.schedule(function() open_ipynb(args.buf) end)
    end,
})
