return {
    "mfussenegger/nvim-dap",
    dependencies = {
        { 
            "rcarriga/nvim-dap-ui",
            dependencies = { "nvim-neotest/nvim-nio" },
        },
        "mfussenegger/nvim-dap-python",
    },
    event = "VeryLazy",
    config = function()
        local dap = require("dap")
        local ui = require("dapui")
        ui.setup()

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

        dap.listeners.before.attach.dapui_config = function()
            ui.open()
        end

        dap.listeners.before.launch.dapui_config = function()
            ui.open()
        end

        dap.listeners.before.event_terminated.dapui_config = function()
            ui.close()
        end

        dap.listeners.before.event_exited.dapui_config = function()
            ui.close()
        end

        require("dap-python").setup("python")
    end,
}
