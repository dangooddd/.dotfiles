return {
    -- surround actions
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup()

            -- add new rules
            local pairs = require("nvim-autopairs")
            local rule = require('nvim-autopairs.rule')
            local cond = require('nvim-autopairs.conds')
            pairs.add_rules({
                rule("$", "$",{ "tex", "latex", "plaintex" })
                -- do not move right when repeat character
                :with_move(cond.none())
            })
        end,
    },
}
