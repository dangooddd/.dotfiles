local wezterm = require "wezterm"
local keybinds = require "keybinds"
local appearance = require "appearance"
local general = require "general"

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
merge(config, general)

return config
