local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",     -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require "lazy".setup {

  "nvim-tree/nvim-web-devicons",   -- pretty icons

  { "mason-org/mason.nvim", config = true },

  {
    "RRethy/vim-illuminate",
    config = function ()
      local illuminate = require 'illuminate'
      -- illuminate.configure({
      --   disable_keymaps = true,
      -- })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('illuminate-lsp', {}),
        callback = function (args)
          illuminate.on_attach(vim.lsp.get_client_by_id(args.data.client_id))
        end
      })
    end
  },

  {
    "windwp/nvim-autopairs",
    event = 'InsertEnter',
    config = { check_ts = true }
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = {
      disable_keymaps = true,
    },
    keys = {
      { "<c-j>", function ()
        local suggestion = require('supermaven-nvim.completion_preview')
        if suggestion.has_suggestion() then
          suggestion.on_accept_suggestion()
        else
          require("supermaven-nvim.api").toggle()
        end
      end, mode = 'i'},
      { "<c-J", function ()
         require('supermaven-nvim.completion_preview').on_accept_word()
      end, mode = 'i'},
    },
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    config = {
      keymaps = {
        useDefaults = true,
        disabledKeymaps = { "gc" },
      },
    }
  },

  {
    "kylechui/nvim-surround",
    event = 'VeryLazy',
    config = true,
  },

  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = {
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },

  {
    "Mofiqul/vscode.nvim",
    config = function()
      if vim.g.vscode_style == nil then

        vim.g.vscode_style = "dark"
        vim.cmd.colorscheme('vscode')
      end
    end
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
      pre_save_cmds = { 'lua require"term".clear()' },
      session_lens = {
        load_on_setup = false,
      },
    }
  },

  {
    "saghen/blink.cmp",
    version = '1.*',
    config = function()
      local blink = require('blink.cmp')
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
              auto_show = require 'filepick'.blink_check_assist,
            },
            list = {
              selection = { preselect = require 'filepick'.blink_check_assist }
            },
          },
          keymap = {
            ['<cr>'] = { 'accept_and_enter', 'fallback' },
          }
        },
      })
      -- setup lsp capabilities
      vim.lsp.config['*'] = {
        capabilities = blink.get_lsp_capabilities(),
      }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require 'nvim-treesitter.configs'.setup({
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = { enable = true },
        rainbow = {
          enable = true,
        },
        indent = {
          enable = true
        },
      })
      vim.cmd('set foldmethod=expr foldexpr=nvim_treesitter#foldexpr() foldlevel=99')
    end
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
    },
    config = {
      graph_style = "unicode",
      process_spinner = true,
      disable_hint = true,
      kind = "auto",
      commit_editor = {
        show_staged_diff = false,
        kind = "split"
      }
    },
    keys = {
      {
        '<leader>g',
        function()
          -- show git status
          local ng = require 'neogit'
          local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
          if ft == 'NeogitStatus' or ft == 'NeogitConsole' then
            -- already showing git, close/hide
            vim.api.nvim_buf_delete(0, { force = false })
          elseif vim.api.nvim_get_option_value('modifiable', { buf = 0 }) == true then
            -- new
            local dir = vim.fn.expand('%:h')
            ng.open({ cwd = dir })
          else
            print('Must be on a file')
          end
        end
      }
    }
  },

}
