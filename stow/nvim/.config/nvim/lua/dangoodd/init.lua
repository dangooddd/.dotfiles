--------------------------------------------------------------------------------
-- init.lua
--------------------------------------------------------------------------------
require("dangoodd.config")
require("dangoodd.lsp")

-- plugins
if not vim.g.vscode then
    require("dangoodd.lazy")
end
