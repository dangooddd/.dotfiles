return {
    "windwp/nvim-autopairs",
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    event = "VeryLazy",
    config = function()
        local pairs = require("nvim-autopairs")
        local cmp_pairs = require("nvim-autopairs.completion.cmp")
        pairs.setup()
        -- enable () after function complete
        require("cmp").event:on(
            "confirm_done",
            cmp_pairs.on_confirm_done()
        )
    end,
}
