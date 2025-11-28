local M = {}

-- Fix Tab conflicts for Vimwiki
vim.cmd [[
  augroup VimwikiTabFix
    autocmd!
    autocmd FileType vimwiki nunmap <buffer> <Tab>
    autocmd FileType vimwiki nunmap <buffer> <S-Tab>
  augroup END
]]



M.ui = {
  theme = "onedark",
  transparency = false,
  
  statusline = {
    theme = "default",
  },
}

M.plugins = {
  "custom.plugins",

  {
    "hrsh7th/cmp-nvim-ultisnips",
    dependencies = "hrsh7th/nvim-cmp",
    opts = {},
  },

  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, 1, { name = "ultisnips" })
    end,
  },
}

M.mappings = require "custom.mappings"

return M
