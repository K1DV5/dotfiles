local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require "lazy".setup {
    "neovim/nvim-lspconfig", -- config in lsp.lua
    { "williamboman/mason.nvim", config = true },
    { "RRethy/vim-illuminate",   lazy = false },

    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },

    { "hrsh7th/nvim-cmp", config = function()
        local cmp = require 'cmp'
        local function complete(direction)
            local key
            if direction == 1 then
                key = 'select_next_item'
            else
                key = 'select_prev_item'
            end
            return function(fallback)
                if cmp.visible() then
                    cmp.mapping[key]()()
                    return
                end
                local col = vim.fn.col '.' - 1
                local not_needed = col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
                if not_needed then
                    fallback()
                    return
                end
                cmp.mapping.complete()
            end
        end

        cmp.setup {
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            formatting = {
                format = function(_, vim_item)
                    return vim_item
                end,
            },
            mapping = {
                ['<CR>'] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Insert,
                    select = true,
                }),
                ['<Tab>'] = complete(1),
                ['<S-Tab>'] = complete(-1),
            },
            preselect = cmp.PreselectMode.None,
            sources = { -- You should specify your *installed* sources.
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
            },
        }
    end },

    "hrsh7th/cmp-buffer",
    { "hrsh7th/cmp-nvim-lsp",  lazy = false },

    { "windwp/nvim-autopairs", config = { check_ts = true } },

    { "chrisgrieser/nvim-various-textobjs", opts = {
        useDefaultKeymaps = true,
        disabledKeymaps = { "gc" },
    } },

    { "nvim-treesitter/nvim-treesitter", config = function()
        require 'nvim-treesitter.configs'.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = { enable = true },
            textobjects = { enable = true },
            rainbow = {
                enable = true,
            },
            textsubjects = {
                enable = true,
                keymaps = {
                    ['.'] = 'textsubjects-smart',
                    [','] = 'textsubjects-container-outer',
                }
            },
            indent = {
                enable = true
            },
        })
        vim.cmd('set foldmethod=expr foldexpr=nvim_treesitter#foldexpr() foldlevel=99')
    end },

    { "ur4ltz/surround.nvim", config = {
        mappings_style = "surround"
    } },

    {
        "jiaoshijie/undotree",
        dependencies = "nvim-lua/plenary.nvim",
        config = true,
        keys = { -- load the plugin only when using it's keybinding:
            { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
        },
    },

    "kyazdani42/nvim-web-devicons", -- pretty icons, for nvim-tree

    { "numToStr/Comment.nvim", opts = { ignore = '^$' }, lazy = false },

    { "Mofiqul/vscode.nvim", config = function()
        if vim.g.vscode_style == nil then
            vim.g.vscode_style = "dark"
            vim.cmd [[colorscheme vscode]]
        end
    end },

    { "nvim-telescope/telescope.nvim", config = function()
        require 'telescope'.setup {
            defaults = {
                preview = false,
                mappings = {
                    i = { ["<esc>"] = require("telescope.actions").close },
                },
            },
            pickers = {
                find_files = {
                    find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
                },
            },
        }
        vim.api.nvim_set_keymap('n', '-', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
    end },

    { "hoob3rt/lualine.nvim", config = {
        options = {
            theme = 'codedark',
            section_separators = { '', '' },
            component_separators = { '', '' },
            disabled_filetypes = { 'aerial' },
        },
        sections = {
            lualine_a = { { function() return vim.api.nvim_get_mode().mode:upper() end, color = 'FocusedSymbol' } },
            lualine_b = {},
            lualine_c = { "require'tabs'.status_text()" },
            lualine_x = { 'diagnostics' },
            lualine_y = {
                { 'fileformat', color = 'FocusedSymbol' },
                { 'filetype',   color = 'FocusedSymbol' }
            },
            lualine_z = { { 'progress', color = 'FocusedSymbol' } },
        },
    } },

    "RRethy/nvim-treesitter-textsubjects",
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",         -- required
            "sindrets/diffview.nvim",        -- optional - Diff integration
            "nvim-telescope/telescope.nvim",
        },
        graph_style = "unicode",
        file_watcher = {
            enabled = false,
        },
        config = {
            kind = "auto",
            commit_editor = {
                show_staged_diff = false,
                kind = "split"
            }
        }
    },
    {
        "rmagatti/auto-session",
        lazy = false,
        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@diagnostic disable-next-line: undefined-doc-name
        ---@type AutoSession.Config
        opts = {
            enabled = true,
            log_level = 'info',
            suppressed_dirs = { "~/", "~/projects" },
            post_restore_cmds = { 'lua require"tabs".all_buffers()' },
            pre_save_cmds = { 'lua require"term".clear()' },
        }
    },
    { "stevearc/aerial.nvim", opts = {
        default_direction = "prefer_left",
        width = 0.17,
    } },
}
-- vim:foldmethod=marker:foldlevel=0
