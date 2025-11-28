
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  command = "setlocal foldmethod=expr foldexpr=VimwikiFoldLevel() foldenable",
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  command = "setlocal foldlevel=99",
})
-- Better LaTeX editing
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.textwidth = 80
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.formatoptions = "tcqjn"
  end,
})
