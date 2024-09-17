return {
    "windwp/nvim-autopairs",
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    event = "VeryLazy",
    config = function()
        local pairs = require("nvim-autopairs")
        local rule = require('nvim-autopairs.rule')
        local cond = require('nvim-autopairs.conds')
        local cmp_pairs = require("nvim-autopairs.completion.cmp")

        pairs.setup()
        -- enable () after function complete
        require("cmp").event:on(
            "confirm_done",
            cmp_pairs.on_confirm_done()
        )

        pairs.add_rules({
            rule("$", "$",{ "tex", "latex" })
                -- do not move right when repeat character
                :with_move(cond.none())
        })
    end,
}
