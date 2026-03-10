--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.guicursor:remove("t:block-blinkon500-blinkoff500-TermCursor")
vim.opt.diffopt = "algorithm:histogram,internal,filler,closeoff,indent-heuristic,linematch:60,context:3"
vim.opt.fillchars:append({ eob = " ", diff = "/" })
vim.opt.winborder = "single"
vim.opt.undofile = true -- save state of file on write
vim.opt.autoread = true -- autoread changes from other sources
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 3
vim.opt.hlsearch = false -- remove highlight on search
vim.opt.mouse = "a"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

vim.opt.pumheight = 10
vim.opt.completeopt = "menu,menuone,noselect,noinsert"
vim.opt.wildmode = "longest:full"
vim.opt.shortmess:append("cC") -- remove completion messages

vim.opt.tabstop = 4 -- 1 tab represented as 4 spaces
vim.opt.expandtab = true -- <tab> key will create " " insead of "\t"
vim.opt.shiftwidth = 4 -- indent change after backspace and >> <<
vim.opt.softtabstop = 4 -- number of spaces instead of tab
vim.opt.autoindent = true -- auto indent
vim.opt.cinkeys:remove(":") -- shit.

vim.g.netrw_banner = 0
vim.g.clipboard = "osc52"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--------------------------------------------------------------------------------
-- Theming
--------------------------------------------------------------------------------
function _G.statusline_diagnostics()
    local count = vim.diagnostic.count(0, {})
    local e = count[vim.diagnostic.severity.ERROR] or 0
    local w = count[vim.diagnostic.severity.WARN] or 0
    local i = count[vim.diagnostic.severity.INFO] or 0

    local parts = {}

    if e > 0 then
        parts[#parts + 1] = "%#DiagnosticError#E:" .. e
    end

    if w > 0 then
        parts[#parts + 1] = "%#DiagnosticWarn#W:" .. w
    end

    if i > 0 then
        parts[#parts + 1] = "%#DiagnosticInfo#I:" .. i
    end

    if #parts == 0 then
        return ""
    end

    return table.concat(parts, " ") .. "%*"
end

vim.o.ruler = false
vim.o.statusline = table.concat({
    " %<%f %m%r",
    "%=",
    "%{%v:lua.statusline_diagnostics()%} %l:%c %p%% ",
})

vim.cmd("colorscheme jungle")

--------------------------------------------------------------------------------
-- Keybinds
--------------------------------------------------------------------------------
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set("n", "<leader>K", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>ql", "<Cmd>copen<CR>")

vim.keymap.set("n", "<leader>qd", function()
    vim.diagnostic.setqflist({ open = false })
end)

vim.keymap.set("n", "<leader>tw", function()
    vim.o.wrap = not vim.o.wrap
end)

vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, {
                autotrigger = true,
                convert = function()
                    return { menu = "" }
                end,
            })
        end
    end,
})

vim.diagnostic.config({ virtual_text = true })

-- rust
vim.lsp.config("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
                experimental = { enable = true },
            },
        },
    },
})
vim.lsp.enable("rust_analyzer")

-- lua
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    "${3rd}/luv/library",
                    vim.fn.stdpath("data") .. "/lazy",
                },
            },
            diagnostics = {
                disable = {
                    "missing-fields",
                },
            },
        },
    },
})
vim.lsp.enable("lua_ls")

-- python
vim.lsp.config("basedpyright", {
    settings = {
        basedpyright = {
            analysis = {
                typeCheckingMode = "standard",
            },
        },
    },
})

vim.lsp.enable("ty")

-- latex
vim.lsp.config("texlab", {
    settings = {
        texlab = {
            build = {
                executable = "latexmk",
                args = {
                    "-lualatex",
                    "-interaction=nonstopmode",
                    "-outdir=build",
                },
                onSave = true,
            },
        },
    },
})
vim.lsp.enable("texlab")

-- shell
vim.lsp.config("bashls", {
    filetypes = { "sh", "zsh" },
    settings = {
        bashIde = {
            shellcheckArguments = {
                "--exclude=SC1090,SC1091,SC2076,SC2164",
            },
        },
    },
})
vim.lsp.enable("bashls")

-- cpp
vim.lsp.enable("clangd")

-- typst
vim.lsp.config["tinymist"] = {
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onSave",
        semanticTokens = "disable",
    },
}
vim.lsp.enable("tinymist")

-- json
vim.lsp.enable("jsonls")
