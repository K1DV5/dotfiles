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

  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",

  "kyazdani42/nvim-web-devicons",   -- pretty icons

  { "williamboman/mason.nvim", config = true },

  { "RRethy/vim-illuminate",   lazy = false },


  {
    "windwp/nvim-autopairs",
    config = { check_ts = true }
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = {
      keymaps = {
        accept_suggestion = "<C-J>",
        accept_word = "<C-]>",
        clear_suggestion = "<C-X>",
      }
    },
    lazy = true,
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
    "ur4ltz/surround.nvim",
    config = {
      mappings_style = "surround"
    }
  },

  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    keys = {     -- load the plugin only when using it's keybinding:
      { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },

  {
    "numToStr/Comment.nvim",
    config = { ignore = '^$' },
    lazy = false
  },

  {
    "Mofiqul/vscode.nvim",
    config = function()
      if vim.g.vscode_style == nil then
        vim.g.vscode_style = "dark"
        vim.cmd [[colorscheme vscode]]
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
    "hrsh7th/nvim-cmp",
    config = function()
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
        formatting = {
          format = function(_, vim_item)
            return vim_item
          end,
        },
        mapping = {
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = false,
          }),
          ['<Tab>'] = complete(1),
          ['<S-Tab>'] = complete(-1),
        },
        window = {
          completion = {
            winhighlight = 'Normal:MoreMsg',
          },
          documentation = {
            winhighlight = 'Normal:MoreMsg',
          },
        },
        preselect = cmp.PreselectMode.None,
        sources = { -- You should specify your *installed* sources.
          { name = 'nvim_lsp' },
          { name = 'buffer' },
        },
      }
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end
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
    end
  },

  "nvim-telescope/telescope-file-browser.nvim",

  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          mappings = {
            i = { ["<esc>"] = require("telescope.actions").close },
          },
          preview = false,
        },
        pickers = {
          find_files = {
            find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
          },
        },
        extensions = {
          file_browser = {
            hijack_netrw = true,
          },
        },
      }
      telescope.load_extension"file_browser"
    end,
    keys = {
      { '-', '<cmd>Telescope find_files<cr>' },
      { '<leader>f', '<cmd>Telescope file_browser<cr>' },
    }
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",        -- required
      "sindrets/diffview.nvim",       -- optional - Diff integration
      "nvim-telescope/telescope.nvim",
    },
    config = {
      graph_style = "unicode",
      file_watcher = {
        enabled = false,
      },
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

  {
    "folke/trouble.nvim",
    opts = {},     -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>D",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>d",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>s",
        "<cmd>Trouble symbols toggle<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>l",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>L",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>Q",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  }

}
