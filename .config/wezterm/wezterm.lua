local wezterm = require "wezterm"

-- merge all parts into config
local config = wezterm.config_builder()
require("keybinds").merge(config)
require("appearance").merge(config)

-- configuration
config.disable_default_key_bindings = true
config.window_close_confirmation = "NeverPrompt"
config.tab_bar_at_bottom = false
config.front_end = "WebGpu"
config.freetype_load_flags = "NO_HINTING"

return config
