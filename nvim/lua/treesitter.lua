ts = require'nvim-treesitter.configs'

ts.setup {
  highlight = {
    enable = true,
    custom_captures = {
      -- Highlight the @foo.bar capture group with the "Identifier" highlight group.
      -- ["foo.bar"] = "Identifier",
    },
  },
  -- indent = {
  --   enable = true
  -- }
}
