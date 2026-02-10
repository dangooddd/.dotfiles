return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
        local palette = require("gruvbox").palette
        require("gruvbox").setup({
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                folds = false,
            },
            contrast = "hard",
            transparent_mode = true,
            overrides = {
                -- builtin
                SignColumn = { bg = "None" },
                CursorLineNr = { bg = "None" },
                Whitespace = { fg = palette.dark0 },
                EndOfBuffer = { fg = palette.dark0_hard },
                Visual = { fg = "None", bg = palette.dark1 },
                Label = { link = "GruvboxPurple" },

                -- blink.cmp
                BlinkCmpMenu = { link = "Normal" },
                BlinkCmpMenuBorder = { link = "BlinkCmpMenu" },
            }
        })
        vim.cmd.colorscheme("gruvbox")
    end,
}
