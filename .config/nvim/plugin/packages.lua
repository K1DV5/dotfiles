-- init script in lua (WIP)

local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'git@github.com:savq/paq-nvim.git', install_path})
end

-- setup packages only if they exist, to not prevent loading other parts
local function setup(path, name, config, setup_func)
    if config == nil then
        config = {}
    elseif type(config) == 'function' then
        local success = pcall(config)
        if not success then
            print('package', name, 'setup error')
        end
        return path
    end
    if setup_func == nil then
        setup_func = 'setup'
    end
    local exists, package = pcall(require, name)
    if exists then
        if package[setup_func] == nil then
            print(name .. '.' .. setup_func, 'not found')
        else
            package[setup_func](config)
        end
    else
        print('package', name, 'not found')
    end
    return path
end

require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself

    "neovim/nvim-lspconfig"; -- config in lsp.lua
    setup("williamboman/mason.nvim", "mason");
    "RRethy/vim-illuminate";

    setup("hrsh7th/nvim-cmp", 'cmp', function()
        local cmp = require'cmp'
        local luasnip = require'luasnip'
        local function complete(direction)
            local key
            if direction == 1 then key = 'select_next_item'
            else key = 'select_prev_item' end
            return function(fallback)
                if cmp.visible() then
                    cmp.mapping[key]()()
                    return
                end
                if luasnip.expand_or_jumpable() then
                    return luasnip.expand_or_jump()
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
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            sources = { -- You should specify your *installed* sources.
              {name = 'nvim_lsp'},
              {name = 'luasnip'},
              {name = 'buffer'},
            },
        }
        vim.api.nvim_set_keymap('s', '<tab>', '<cmd>lua require("luasnip").jump(1)<cr>', {noremap = true, silent = true})
        vim.api.nvim_set_keymap('s', '<s-tab>', '<cmd>lua require("luasnip").jump(-1)<cr>', {noremap = true, silent = true})
        require("luasnip.loaders.from_vscode").lazy_load()
        -- require("nvim-autopairs.completion.cmp").setup({
        --   map_cr = true, --  map <CR> on insert mode
        --   map_complete = true, -- it will auto insert `(` after select function or method item
        -- })
    end);

    "hrsh7th/cmp-buffer";
    "hrsh7th/cmp-nvim-lsp";
    "rafamadriz/friendly-snippets";

    setup("windwp/nvim-autopairs", 'nvim-autopairs', { check_ts = true });

    setup("nvim-treesitter/nvim-treesitter", 'nvim-treesitter.configs', {
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
                [';'] = 'textsubjects-container-outer',
            }
        },
        indent = {
            enable = true
        },
        vim.cmd('set foldmethod=expr foldexpr=nvim_treesitter#foldexpr() foldlevel=99')
    });

    setup("ur4ltz/surround.nvim", 'surround', {
        mappings_style = "surround"
    });

    "kyazdani42/nvim-web-devicons";  -- pretty icons, for nvim-tree

    "ggandor/lightspeed.nvim";  -- move fast in nvim

    "JoosepAlviste/nvim-ts-context-commentstring";

    setup("terrortylor/nvim-comment", 'nvim_comment', {
        comment_empty = false
    });

    setup("Mofiqul/vscode.nvim", 'vscode', function()
        if vim.g.vscode_style == nil then
            vim.g.vscode_style = "dark"
            vim.cmd[[colorscheme vscode]]
        end
    end);

    "L3MON4D3/LuaSnip";
    "saadparwaiz1/cmp_luasnip";

    setup("jakewvincent/mkdnflow.nvim", 'mkdnflow');

    setup("nvim-telescope/telescope.nvim", 'telescope', function()
        require'telescope'.setup{
            defaults = {
                preview = false,
                mappings = {
                    i = {["<esc>"] = require("telescope.actions").close},
                },
            }
        }
        vim.api.nvim_set_keymap('n', '-', '<cmd>Telescope find_files<CR>', {noremap = true, silent = true})
    end);

    setup("hoob3rt/lualine.nvim", 'lualine', {
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
    });

    "RRethy/nvim-treesitter-textsubjects";

    "nvim-lua/plenary.nvim"; -- for neogit, gitsigns

    setup("TimUntersberger/neogit", 'neogit', { auto_refresh = false });

    setup("rmagatti/auto-session", 'auto-session', {
        log_level = 'info',
        auto_session_suppress_dirs = {'~/', '~/projects'},
        post_restore_cmds = {'lua tabs_all_buffers()'},
        pre_save_cmds = {'lua clear_terms()'},
    });
    setup("stevearc/aerial.nvim", "aerial", {
        default_direction = "prefer_left",
        width = 0.17,
    });
}

-- vim:foldmethod=marker:foldlevel=0
