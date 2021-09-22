-- init script in lua (WIP)

local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end

-- setup packages only if they exist, to not prevent loading other parts
local function setup(name, config, setup_func)
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
end

require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself

    "neovim/nvim-lspconfig"; -- config in lsp.lua

    "hrsh7th/nvim-cmp"; -- {{{
        (function()
            local lspkind = require'lspkind'
            local cmp = require'cmp'
            local luasnip = require'luasnip'
            cmp.setup{
                formatting = {
                    format = function(entry, vim_item)
                        vim_item.kind = lspkind.presets.default[vim_item.kind]
                        return vim_item
                    end,
                },
                mapping = {
                    ['<CR>'] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    })
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                sources = { -- You should specify your *installed* sources.
                  {name = 'nvim_lsp'},
                  {name = 'luasnip'},
                  {name = 'treesitter'},
                  -- {name = 'buffer'},
                },
            }
            -- require("nvim-autopairs.completion.cmp").setup({
            --   map_cr = true, --  map <CR> on insert mode
            --   map_complete = true, -- it will auto insert `(` after select function or method item
            -- })
        end)(); -- }}}
    "hrsh7th/cmp-buffer";
    "hrsh7th/cmp-nvim-lsp";
    "ray-x/cmp-treesitter";

    "windwp/nvim-autopairs"; -- {{{
        setup('nvim-autopairs', {}); -- }}}
    "nvim-treesitter/nvim-treesitter"; -- {{{
        setup('nvim-treesitter.configs', {
            highlight = { enable = true },
            incremental_selection = { enable = true },
            textobjects = { enable = true },
            rainbow = {
                enable = true,
            },
            context_commentstring = {
                enable = true
            }
        }); -- }}}
    "blackCauldron7/surround.nvim"; -- {{{
        setup('surround', {
            mappings_style = "surround"
        });
        -- }}}
    "kyazdani42/nvim-tree.lua"; -- file manager
        (function()
            vim.g.nvim_tree_show_icons = {git = 0, folders = 1, files = 1, folder_arrows = 1}
            vim.g.nvim_tree_lsp_diagnostics = 1
        end)();
    "kyazdani42/nvim-web-devicons";  -- pretty icons, for nvim-tree, lspkind-nvim
    -- diagnostics window
    "folke/trouble.nvim"; -- {{{
        setup('trouble', {});
        -- }}}
    -- pretty icons on lsp completion items
    "onsails/lspkind-nvim"; -- {{{
        setup('lspkind', {
            with_text = false
        }, 'init');
        -- }}}
    "ggandor/lightspeed.nvim";  -- move fast in nvim
    "p00f/nvim-ts-rainbow";
    "JoosepAlviste/nvim-ts-context-commentstring";
    "terrortylor/nvim-comment";  -- {{{
        setup('nvim_comment', {
            comment_empty = false
        }); -- }}}
    -- vscode's dark+ theme
    "Mofiqul/vscode.nvim";  -- {{{
        (function()
            if vim.g.vscode_style == nil then
                vim.g.vscode_style = "dark"
                vim.cmd[[colorscheme vscode]]
            end
        end)();
    -- }}}
    "L3MON4D3/LuaSnip";
    "saadparwaiz1/cmp_luasnip";
    "simrat39/symbols-outline.nvim";
    "tversteeg/registers.nvim";
    "jakewvincent/mkdnflow.nvim";  -- {{{
        setup('mkdnflow', {});
    -- }}}
    {"camspiers/snap", run='curl https://raw.githubusercontent.com/swarn/fzy-lua/main/src/fzy_lua.lua -o ' .. fn.stdpath('config') ..  '/lua/fzy.lua'}; -- {{{
        (function()
            local snap = require'snap'
            snap.maps{
                {"<Leader><Leader>", snap.config.file {producer = "ripgrep.file", consumer = "fzy"}},
                {"<Leader>fb", snap.config.file {producer = "vim.buffer", consumer = "fzy"}},
                {"<Leader>fo", snap.config.file {producer = "vim.oldfile", consumer = "fzy"}},
                {"<Leader>ff", snap.config.vimgrep {consumer = "fzy"}},
            }
        end
        )(); -- }}}

    -- look for alternatives
    "mattn/emmet-vim";
    "mbbill/undotree";
    "mhinz/vim-signify";
    "lambdalisue/gina.vim";
}

-- vim:foldmethod=marker:foldlevel=0
