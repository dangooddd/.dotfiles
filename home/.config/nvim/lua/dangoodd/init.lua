---------------------------------------
-- init.lua
---------------------------------------
require("dangoodd.config")

-- plugins
if not vim.g.vscode then
    require("dangoodd.lazy")
end
