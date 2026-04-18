-- =====================
-- Bootstrap lazy.nvim
-- =====================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-- =====================
-- General settings
-- =====================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- =====================
-- Plugins
-- =====================
require("lazy").setup({

    spec = {

        -- Core
        { "nvim-lua/plenary.nvim" },

        -- Telescope
        {
            "nvim-telescope/telescope.nvim",
            cmd = "Telescope",
            dependencies = { "nvim-lua/plenary.nvim" },
            config = function()
                local builtin = require("telescope.builtin")

                vim.keymap.set("n", "<leader>ff", builtin.find_files)
                vim.keymap.set("n", "<leader>fg", builtin.live_grep)
                vim.keymap.set("n", "<leader>fb", builtin.buffers)
                vim.keymap.set("n", "<leader>fh", builtin.help_tags)

                require("telescope").setup({
                    pickers = {
                        find_files = {
                            find_command = {
                                "rg", "--files", "--hidden",
                                "--glob", "!**/.git/*"
                            },
                        },
                    },
                })
            end,
        },

        -- Treesitter (FIXED LOADING)
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            event = { "BufReadPost", "BufNewFile" },
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "go", "lua", "vim", "vimdoc" },
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end,
        },

        -- Statusline
        {
            "nvim-lualine/lualine.nvim",
            event = "VeryLazy",
            config = function()
                require("lualine").setup({})
            end,
        },

        -- Git
        {
            "lewis6991/gitsigns.nvim",
            event = "BufReadPre",
            config = function()
                require("gitsigns").setup()
            end,
        },

        -- Theme
        {
            "EdenEast/nightfox.nvim",
            priority = 1000,
            lazy = false,
            config = function()
                vim.cmd("colorscheme nightfox")
            end,
        },

        -- Completion
        {
            "hrsh7th/nvim-cmp",
            event = "InsertEnter",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "L3MON4D3/LuaSnip",
            },
            config = function()
                local cmp = require("cmp")
                local luasnip = require("luasnip")

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                        ["<Tab>"] = cmp.mapping.select_next_item(),
                        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                    }),
                    sources = {
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                    },
                })
            end,
        },

        -- LSP (MODERN API)
        {
            "neovim/nvim-lspconfig",
            event = { "BufReadPre", "BufNewFile" },
            config = function()
                local capabilities =
                    require("cmp_nvim_lsp").default_capabilities()

                vim.lsp.config("gopls", {
                    capabilities = capabilities,
                })

                vim.lsp.enable("gopls")
            end,
        },

        -- Go support
        {
            "ray-x/go.nvim",
            ft = { "go", "gomod" },
            dependencies = {
                "ray-x/guihua.lua",
                "nvim-treesitter/nvim-treesitter",
            },
            build = ':lua require("go.install").update_all_sync()',
            config = function()
                require("go").setup()

                vim.api.nvim_create_autocmd("BufWritePre", {
                    pattern = "*.go",
                    callback = function()
                        require("go.format").goimports()
                    end,
                })
            end,
        },

    },

    checker = { enabled = true },

})
