return {
  {
    "vimwiki/vimwiki",
    lazy = false,  -- ensures it's loaded immediately
    init = function()
      vim.g.vimwiki_list = {
        {
          path = '~/vimwiki/',
          syntax = 'default',
          ext = '.wiki',
        },
      }
    end,
  },
  
  -- LaTeX support with VimTeX
  {
    "lervag/vimtex",
    ft = "tex",  -- lazy load only for .tex files
    config = function()
      -- PDF viewer setup for Mac
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_synctex = 0
      
      -- Compiler configuration
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      
      -- Performance optimizations
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_enabled = 1

       -- Concealment settings (from the article)
      vim.g.tex_flavor = 'latex'
      vim.g.tex_conceal = 'abdmg'     

      -- Don't auto-open quickfix for warnings
      vim.g.vimtex_quickfix_open_on_warning = 0
    end,
  },

  {
    "SirVer/ultisnips",
    ft = "tex",
    dependencies = {
      "honza/vim-snippets",  -- optional: community snippets
    },
    config = function()
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
      
      -- Snippet directories
    vim.g.UltiSnipsSnippetDirectories = { vim.fn.stdpath("config") .. "/my_snippets", "UltiSnips" }      
      -- Edit snippets in vertical split
      vim.g.UltiSnipsEditSplit = "vertical"
    end,
  },
}
