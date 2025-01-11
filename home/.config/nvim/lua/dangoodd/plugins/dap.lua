return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap",
        "mfussenegger/nvim-dap-python",
    },
    event = "VeryLazy",
    config = function()
        require("dapui").setup({ expand_lines = false })
        require("dap-python").setup("python")

        -- dap keybinds
        local dap = require("dap")
        local ui = require("dapui")

        vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
        vim.keymap.set("n", "<space>dr", dap.run_to_cursor)
        vim.keymap.set("n", "<F1>", dap.continue)
        vim.keymap.set("n", "<F2>", dap.step_into)
        vim.keymap.set("n", "<F3>", dap.step_over)
        vim.keymap.set("n", "<F4>", dap.step_out)
        vim.keymap.set("n", "<F5>", dap.step_back)
        vim.keymap.set("n", "<F6>", dap.terminate)
        vim.keymap.set("n", "<F7>", dap.disconnect)
        vim.keymap.set("n", "<F12>", dap.restart)

        dap.listeners.before.attach.dapui_config = ui.open
        dap.listeners.before.launch.dapui_config = ui.open
        dap.listeners.before.event_terminated.dapui_config = ui.close
        dap.listeners.before.event_exited.dapui_config = ui.close
    end,
}
