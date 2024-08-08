local wezterm = require "wezterm"
local keybinds = require "keybinds"
local appearance = require "appearance"

-- merge two tables in one
function merge(t1, t2)
    for k, v in pairs(t2) do
        t1[k] = v
    end
end

-- merge all parts into config
local config = wezterm.config_builder()
merge(config, keybinds)
merge(config, appearance)

-- configuration
config.disable_default_key_bindings = true
config.window_close_confirmation = "NeverPrompt"
config.tab_bar_at_bottom = false

return config
