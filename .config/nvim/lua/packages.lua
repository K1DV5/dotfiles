-- $$ nvim -l %f

local gh = "https://github.com/"

local function pack_add(spec)
  vim.pack.add(spec)
  for i, val in ipairs(spec) do
    if type(val) == "string" then
      goto continue
    end
    if val.config == true then
      require(val.name).setup{}
    elseif type(val.config) == "function" then
      val.config()
    end
    ::continue::
  end
end

pack_add{

  gh .. "nvim-tree/nvim-web-devicons",

  {
    src = gh .. "tpope/vim-fugitive",
    config = function ()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fugitive',
        callback = function()
          vim.keymap.set('n', '<tab>', '=', { buffer = 0, remap = true })
          vim.keymap.set('n', 'P', '<cmd>G push<cr>', { buffer = 0 })
          vim.keymap.set('n', 'p', '<cmd>G pull<cr>', { buffer = 0 })
        end
      })
      vim.keymap.set('n', '<leader>g', function()
        local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
        if ft == 'fugitive' or ft == 'gitcommit' then
          vim.api.nvim_buf_delete(0, { force = false })
        elseif vim.api.nvim_get_option_value('modifiable', { buf = 0 }) == true then
          vim.cmd'vertical Git'
        else
          print('Must be on a file')
        end
      end)
    end,
  },

  {
    src = gh .. "mason-org/mason.nvim",
    name = 'mason',
    config = true
  },

  {
    src = gh .. "RRethy/vim-illuminate",
    name = 'illuminate',
    config = function ()
      local illuminate = require'illuminate'
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('illuminate-lsp', {}),
        callback = function (args)
          illuminate.on_attach(vim.lsp.get_client_by_id(args.data.client_id))
        end
      })
    end
  },

  {
    src = gh .. "windwp/nvim-autopairs",
    name = 'nvim-autopairs',
    config = function() require'nvim-autopairs'.setup{ check_ts = true } end
  },

  {
    src = gh .. "chrisgrieser/nvim-various-textobjs",
    name = 'various-textobjs',
    config = function()
      require'various-textobjs'.setup{
        keymaps = {
          useDefaults = true,
          disabledKeymaps = { "gc" },
        },
      }
    end
  },

  {
    src = gh .. "kylechui/nvim-surround",
    name = 'nvim-surround',
    config = true,
  },

  gh .. "nvim-lua/plenary.nvim",

  {
    src = gh .. "jiaoshijie/undotree",
    name = 'undotree',
    config = function()
        local ut = require'undotree'
        ut.setup{}
        vim.keymap.set('n', '<leader>u', ut.toggle)
    end,
  },

  {
    src = gh .. "Mofiqul/vscode.nvim",
    config = function()
      if vim.g.vscode_style == nil then
        vim.g.vscode_style = "dark"
        vim.cmd.colorscheme('vscode')
      end
    end
  },

  {
    src = gh .. "rmagatti/auto-session",
    name = 'auto-session',
    config = function()
      require'auto-session'.setup{
        enabled = true,
        log_level = 'info',
        suppressed_dirs = { "~/", "~/projects" },
        auto_delete_empty_sessions = true,
        purge_after_minutes = 30 * 24 * 60, -- a month
        pre_save_cmds = { 'lua require"term".clear()' },
        session_lens = {
          load_on_setup = false,
        },
      }
    end
  },

  {
    src = gh .. "saghen/blink.cmp",
    version = vim.version.range('1.x'),
    config = function()
      local blink = require('blink.cmp')
      local fuzzy = require('fuzzy')
      blink.setup({
        keymap = {
          preset = 'default',
          ['<tab>'] = { 'select_next', 'fallback' },
          ['<s-tab>'] = { 'snippet_forward', 'select_prev', 'fallback' },
          ['<c-s-tab>'] = { 'snippet_backward', 'fallback' },
          ['<cr>'] = { 'accept', 'fallback' },
        },
        fuzzy = {
          max_typos = function() return 0 end,
          sorts = {
            'exact',
            -- defaults
            'score',
            'sort_text',
          },
        },
        completion = {
          list = {
            selection = { preselect = false },
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
          },
        },
        cmdline = {
          completion = {
            menu = {
              auto_show = fuzzy.blink_check_assist,
            },
            list = {
              selection = { preselect = fuzzy.blink_check_assist }
            },
          },
          keymap = {
            ['<cr>'] = { 'accept_and_enter', 'fallback' },
          }
        },
      })
      vim.lsp.config['*'] = {
        capabilities = blink.get_lsp_capabilities(),
      }
    end,
  },

  {
    src = gh .. "nvim-treesitter/nvim-treesitter",
    name = 'nvim-treesitter',
    config = function()
      local parsers = { 'svelte', 'markdown', 'javascript', 'typescript', 'html', 'css', 'scss', 'astro', 'typst', 'python', 'go', typescriptreact = 'tsx', javascriptreact = 'jsx' }
      require('nvim-treesitter').install(vim.tbl_values(parsers))
      vim.api.nvim_create_autocmd('FileType', {
        pattern = vim.tbl_map(
          function(v)
            if type(v) == 'string' then
              return v
            end
            return parsers[v]
          end,
          vim.tbl_keys(parsers)
        ),
        callback = function() 
          vim.treesitter.start()
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
          vim.wo[0][0].foldlevel = 99
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end
  },

}
