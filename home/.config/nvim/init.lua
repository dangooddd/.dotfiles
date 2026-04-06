--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
vim.o.winborder = "single"
vim.o.undofile = true -- save state of file on write
vim.o.autoread = true -- read changes from other sources
vim.o.wrap = false
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 3
vim.o.hlsearch = false
vim.o.mouse = "a"
vim.o.fillchars = "eob: ,diff:/"
vim.o.diffopt = vim.o.diffopt .. ",algorithm:histogram"
vim.o.guicursor = "n-v-c-ci:block,i-ve:ver25,r-cr-o:hor20,t:block-TermCursor"

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.pumheight = 10
vim.o.pumborder = vim.o.winborder
vim.o.completeopt = "menu,menuone,noselect,noinsert"
vim.o.wildmode = "longest:full"
vim.o.shortmess = vim.o.shortmess .. "c" -- remove completion messages

vim.o.tabstop = 4 -- 1 tab represented as 4 spaces
vim.o.expandtab = true -- <tab> key will create " " insead of "\t"
vim.o.shiftwidth = 4 -- indent change after backspace and >> <<
vim.o.softtabstop = 4 -- number of spaces instead of tab
vim.o.autoindent = true

vim.o.langmap = [[йq,цw,уe,кr,еt,нy,гu,шi,щo,зp,х[,ъ],]]
    .. [[фa,ыs,вd,аf,пg,рh,оj,лk,дl,ж\;,э',]]
    .. [[яz,чx,сc,мv,иb,тn,ьm,б\,,ю.,]]
    .. [[ЁQ,ЦW,УE,КR,ЕT,НY,ГU,ШI,ЩO,ЗP,Х{,Ъ},]]
    .. [[ФA,ЫS,ВD,АF,ПG,РH,ОJ,ЛK,ДL,Ж\:,Э",]]
    .. [[ЯZ,ЧX,СC,МV,ИB,ТN,ЬM,Б<,Ю>]]

vim.g.netrw_banner = 0
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.diagnostic.config({
    virtual_text = true,
    status = {
        format = {
            [vim.diagnostic.severity.ERROR] = "%#DiagnosticError#E",
            [vim.diagnostic.severity.WARN] = "%#DiagnosticWarn#W",
            [vim.diagnostic.severity.INFO] = "%#DiagnosticInfo#I",
            [vim.diagnostic.severity.HINT] = "%#DiagnosticHint#H",
        },
    },
})

require("vim._core.ui2").enable({ enable = true })

--------------------------------------------------------------------------------
-- Theme
--------------------------------------------------------------------------------
function _G.Tabline()
    local s = ""

    for i = 1, vim.fn.tabpagenr("$") do
        local is_current = (i == vim.fn.tabpagenr())
        local win = vim.fn.tabpagewinnr(i)
        local buf = vim.fn.tabpagebuflist(i)[win]
        local name = vim.api.nvim_buf_get_name(buf):gsub("/+$", "")
        local close = vim.bo[buf].modified and " + " or " X "
        name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")

        s = s .. " " .. (is_current and "%#TabLineSel#" or "%#TabLine#")
        s = s .. "%" .. i .. "T"
        s = s .. name .. "%" .. i .. "X" .. close
        s = s .. "%" .. i .. "T"
    end

    s = s .. "%#TabLineFill#%T"

    return s
end

function _G.Statusline()
    local s = " %<%f %m%r%="
    local progress = vim.ui.progress_status()
    local diagnostic = vim.diagnostic.status()

    if #progress > 0 then
        s = s .. " " .. progress
    end

    if #diagnostic > 0 then
        s = s .. " " .. diagnostic
    end

    s = s .. " %l:%c %p%% "
    return s
end

vim.cmd("colorscheme jungle")
vim.o.ruler = false
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.statusline = "%!v:lua.Statusline()"

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
vim.pack.add({
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/kylechui/nvim-surround",
    "https://github.com/nvim-mini/mini.icons",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
}, {
    confirm = false,
    load = true,
})

vim.cmd("packadd nvim.difftool")
vim.cmd("packadd nvim.undotree")

require("placeholders").setup()
require("ipython").setup()
require("jupytext").setup()

require("nvim-treesitter").setup()
require("nvim-surround").setup()
require("mini.icons").setup()
require("mason").setup({ ui = { backdrop = 100 } })

require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        lua = { "stylua" },
    },
    format_after_save = function(bufnr)
        if not vim.b[bufnr].conform_stop then
            return { lsp_format = "fallback" }
        end
    end,
})

require("fzf-lua").setup({
    winopts = {
        backdrop = 100,
        title_flags = false,
        border = vim.o.winborder,
        preview = {
            horizontal = "right:50%",
            layout = "horizontal",
            border = vim.o.winborder,
        },
    },
})

require("oil").setup({
    default_file_explorer = true,
    columns = { { "icon", add_padding = false } },
    view_options = { show_hidden = true },
    float = {
        max_width = 0.8,
        preview_split = "right",
        win_options = { winhighlight = "NormalNC:NormalFloat" },
    },
})

--------------------------------------------------------------------------------
-- Keybinds / Commands
--------------------------------------------------------------------------------
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "x" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "x" }, "<leader>P", '"+P')

vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set("n", "<leader>q", "<Cmd>copen<CR>")

vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.setqflist({ open = true })
end)

vim.keymap.set("n", "<leader>tw", function()
    vim.o.wrap = not vim.o.wrap
end)

vim.keymap.set("n", "<leader>th", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end)

vim.api.nvim_create_user_command("ConformToggle", function()
    vim.b.conform_stop = not vim.b.conform_stop
end, {})

vim.keymap.set("n", [[<leader>\]], require("oil").toggle_float)

vim.keymap.set("n", "<leader>je", require("jupytext").export_to_notebook)

vim.keymap.set("n", "<leader>ff", require("fzf-lua").files)
vim.keymap.set("n", "<leader>fh", require("fzf-lua").helptags)
vim.keymap.set("n", "<leader>fb", require("fzf-lua").buffers)
vim.keymap.set("n", "<leader>fg", require("fzf-lua").git_files)
vim.keymap.set("n", "<leader>fd", require("fzf-lua").diagnostics_workspace)
vim.keymap.set("n", "<leader>fl", require("fzf-lua").live_grep)
vim.keymap.set("n", "<leader>fz", require("fzf-lua").builtin)
vim.keymap.set("n", "<leader>fr", require("fzf-lua").resume)

vim.keymap.set("n", "<leader>jo", require("ipython").toggle_repl)
vim.keymap.set("n", "<leader>jc", require("ipython").close_repl)
vim.keymap.set("n", "<leader>ji", require("ipython").open_history)
vim.keymap.set("v", "<leader>jv", require("ipython").send_visual)
vim.keymap.set("n", "<leader>js", require("ipython").install_packages)
vim.keymap.set({ "n", "t" }, "<C-j>", require("ipython").toggle_repl_focus)

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------
local langs = {}
for _, value in ipairs(require("nvim-treesitter").get_available()) do
    langs[value] = true
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = vim.schedule_wrap(function(event)
        local lang = vim.treesitter.language.get_lang(event.match)
        if not langs[lang] then
            return
        end

        local ok, _ = pcall(vim.treesitter.start, event.buf)
        if not ok then
            require("nvim-treesitter").install(lang)
        end
    end),
})

local chars = {}
for i = 32, 126 do
    chars[#chars + 1] = string.char(i)
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))

        if client:supports_method("textDocument/completion") then
            local provider = client.server_capabilities.completionProvider or {}
            provider.triggerCharacters = chars
            client.server_capabilities.completionProvider = provider

            vim.lsp.completion.enable(true, client.id, event.buf, {
                autotrigger = true,
                convert = function()
                    return { menu = "" }
                end,
            })
        end
    end,
})

--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------
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

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt"),
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

vim.lsp.config("tinymist", {
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onSave",
        semanticTokens = "disable",
    },
})

vim.lsp.enable("ruff")
vim.lsp.enable("ty")
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("texlab")
vim.lsp.enable("bashls")
vim.lsp.enable("tinymist")
vim.lsp.enable("jsonls")
vim.lsp.enable("rust_analyzer")
