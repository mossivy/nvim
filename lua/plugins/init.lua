return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  -- VimTeX configuration
  {
    "lervag/vimtex",
    lazy = false,  -- Don't lazy load vimtex
    init = function()
      -- Use 'init' to set vim.g variables before plugin loads
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
    end,
  },
}
