-- init script in lua (WIP)

return {

    "neovim/nvim-lspconfig", -- config in lsp.lua
    {"williamboman/mason.nvim", config = true},
    {"RRethy/vim-illuminate", lazy = false},

    {"hrsh7th/nvim-cmp", config = function()
        local cmp = require'cmp'
        local function complete(direction)
            local key
            if direction == 1 then key = 'select_next_item'
            else key = 'select_prev_item' end
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

        cmp.setup{
            formatting = {
                format = function(entry, vim_item)
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
              {name = 'nvim_lsp'},
              {name = 'buffer'},
            },
        }
    end},

    "hrsh7th/cmp-buffer",
    {"hrsh7th/cmp-nvim-lsp", lazy = false},

    {"windwp/nvim-autopairs", config = { check_ts = true }},

    {"nvim-treesitter/nvim-treesitter", config = function()
        require'nvim-treesitter.configs'.setup({
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = { enable = true },
            textobjects = { enable = true },
            rainbow = {
                enable = true,
            },
            context_commentstring = {
                enable = true
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
    end},

    {"ur4ltz/surround.nvim", config = {
        mappings_style = "surround"
    }},

    "kyazdani42/nvim-web-devicons",  -- pretty icons, for nvim-tree

    "JoosepAlviste/nvim-ts-context-commentstring",

    {"terrortylor/nvim-comment", config = {
        comment_empty = false
    }},

    {"Mofiqul/vscode.nvim", config = function()
        if vim.g.vscode_style == nil then
            vim.g.vscode_style = "dark"
            vim.cmd[[colorscheme vscode]]
        end
    end},

    {"nvim-telescope/telescope.nvim", config = function()
        require'telescope'.setup{
            defaults = {
                preview = false,
                mappings = {
                    i = {["<esc>"] = require("telescope.actions").close},
                },
            }
        }
        vim.api.nvim_set_keymap('n', '-', '<cmd>Telescope find_files<CR>', {noremap = true, silent = true})
    end},

    {"hoob3rt/lualine.nvim", config = {
        options = {
            theme = 'codedark',
            section_separators = {'', ''},
            component_separators = {'', ''},
            disabled_filetypes = {'aerial'},
        },
        sections = {
            lualine_a = {{function() return vim.api.nvim_get_mode().mode:upper() end, color = 'FocusedSymbol'}},
            lualine_b = {},
            lualine_c = {"tabs_status_text()"},
            lualine_x = {'diagnostics'},
            lualine_y = {
                {'fileformat', color = 'FocusedSymbol'},
                {'filetype', color = 'FocusedSymbol'}
            },
            lualine_z = {{'progress', color = 'FocusedSymbol'}},
        },
    }},

    "RRethy/nvim-treesitter-textsubjects",

    "nvim-lua/plenary.nvim", -- for neogit, gitsigns

    {"rmagatti/auto-session", config = {
        log_level = 'info',
        auto_session_suppress_dirs = {'~/', '~/projects'},
        post_restore_cmds = {'lua tabs_all_buffers()'},
        pre_save_cmds = {'lua clear_terms()'},
    }},
    {"stevearc/aerial.nvim", config = {
        default_direction = "prefer_left",
        width = 0.17,
    }},
}

-- vim:foldmethod=marker:foldlevel=0
