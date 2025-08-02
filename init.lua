local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

-- General settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
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
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.o.laststatus = 3
vim.opt.fixendofline = false
vim.opt.eol = false

-- Disable language providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

require("lazy").setup({
    spec = {
        { "nvim-lua/plenary.nvim" },
        { "sharkdp/fd" },

        {
            "nvim-telescope/telescope.nvim",
            dependencies = { "nvim-lua/plenary.nvim" },
            config = function()
                local builtin = require('telescope.builtin')
                vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
                vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
                vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
                vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

                require('telescope').setup({
                    pickers = {
                        find_files = {
                            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                        },
                    },
                })
            end,
        },

        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require('nvim-treesitter.configs').setup({
                    highlight = { enable = true }
                })
            end,
        },

        {
            "nvim-lualine/lualine.nvim",
            config = function()
                require("lualine").setup({})
            end,
        },

        {
            "sindrets/diffview.nvim",
            config = function()
                require("diffview").setup({})
            end,
        },

        { "nvim-tree/nvim-web-devicons" },

        {
            "EdenEast/nightfox.nvim",
            priority = 1000,
            config = function()
                vim.cmd("colorscheme nightfox")
                vim.cmd([[highlight ColorColumn guibg=#51202A]])
                vim.opt.colorcolumn = "80,120"
            end,
        },

        {
            "lewis6991/gitsigns.nvim",
            config = function()
                require("gitsigns").setup({
                    signs = {
                        add          = { text = '┃' },
                        change       = { text = '┃' },
                        delete       = { text = '_' },
                        topdelete    = { text = '‾' },
                        changedelete = { text = '~' },
                        untracked    = { text = '┆' },
                    },
                    signs_staged = {
                        add          = { text = '┃' },
                        change       = { text = '┃' },
                        delete       = { text = '_' },
                        topdelete    = { text = '‾' },
                        changedelete = { text = '~' },
                        untracked    = { text = '┆' },
                    },
                    signcolumn = true,
                    current_line_blame = false,
                    current_line_blame_opts = {
                        virt_text = true,
                        virt_text_pos = 'eol',
                        delay = 1000,
                        ignore_whitespace = false,
                        virt_text_priority = 100,
                        use_focus = true,
                    },
                    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
                    sign_priority = 6,
                    update_debounce = 100,
                    max_file_length = 200000,
                    preview_config = {
                        style = 'minimal',
                        relative = 'cursor',
                        row = 0,
                        col = 1
                    },
                })

                local gitsigns = require("gitsigns")
                vim.keymap.set('n', '<leader>gn', gitsigns.next_hunk, { desc = 'Gitsigns next hunk' })
                vim.keymap.set('n', '<leader>gp', gitsigns.prev_hunk, { desc = 'Gitsigns prev hunk' })
            end,
        },

        {
            "hrsh7th/nvim-cmp",
            dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" },
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
                        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-d>'] = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                        ['<Tab>'] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then
                                luasnip.expand_or_jump()
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),
                        ['<S-Tab>'] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { 'i', 's' }),
                    }),
                    sources = {
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                    },
                })
            end,
        },

        {
            "neovim/nvim-lspconfig",
            config = function()
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                require("lspconfig").gopls.setup({ capabilities = capabilities })
                require("lspconfig").clangd.setup({
                    capabilities = capabilities,
                    on_attach = function(_, bufnr)
                        local opts = { noremap = true, silent = true }
                        local map = vim.api.nvim_buf_set_keymap
                        map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                        map(bufnr, 'n', 'gI', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                    end,
                })
            end,
        },

        {
            "SmiteshP/nvim-navbuddy",
            dependencies = {
                "neovim/nvim-lspconfig",
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim",
            },
            keys = {
                { "<leader>nv", "<cmd>Navbuddy<cr>", desc = "Nav" },
            },
            config = function()
                local navbuddy = require("nvim-navbuddy")
                local actions = require("nvim-navbuddy.actions")
                navbuddy.setup({
                    window = { border = "double" },
                    mappings = {
                        ["k"] = actions.next_sibling,
                        ["i"] = actions.previous_sibling,
                        ["j"] = actions.parent,
                        ["l"] = actions.children,
                    },
                    lsp = { auto_attach = true },
                })
            end,
        },

        {
            "ray-x/go.nvim",
            dependencies = {
                "ray-x/guihua.lua",
                "neovim/nvim-lspconfig",
                "nvim-treesitter/nvim-treesitter",
            },
            event = { "CmdlineEnter" },
            ft = { "go", "gomod" },
            build = ':lua require("go.install").update_all_sync()',
            config = function(_, opts)
                require("go").setup(opts)
                local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
                vim.api.nvim_create_autocmd("BufWritePre", {
                    pattern = "*.go",
                    callback = function()
                        require("go.format").goimports()
                    end,
                    group = format_sync_grp,
                })
            end,
        },
    },
    checker = { enabled = true },
})
