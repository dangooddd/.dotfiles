--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------

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
vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--fallback-style=llvm",
        "--header-insertion=iwyu",
        "-j=4",
    },
})
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
