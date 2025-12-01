-- LaTeX-specific settings for note-taking workflow
local opts = { buffer = true, silent = true }

-- Set localleader to comma
vim.g.maplocalleader = ","

vim.filetype.add {
  extension = {
    tex = "tex",
  }
}

-- Write server name to file for inverse search
local function write_server_name()
  local nvim_server_file = '/tmp/vimtexserver.txt'
  local f = io.open(nvim_server_file, 'w')
  if f then
    f:write(vim.v.servername)
    f:close()
  end
end

-- Auto-load course-specific snippets based on current file location
local function setup_course_snippets()
  local current_file = vim.fn.expand('%:p')
  local school_dir = vim.fn.expand('~/School/')
  
  if vim.startswith(current_file, school_dir) then
    local relative_path = current_file:sub(#school_dir + 1)
    local course_path = relative_path:match('^([^/]+/[^/]+)/')
    
    if course_path then
      local course_dir = school_dir .. course_path
      if vim.fn.isdirectory(course_dir) == 1 then
        local already_added = false
        for _, path in ipairs(vim.opt.runtimepath:get()) do
          if path == course_dir then
            already_added = true
            break
          end
        end
        if not already_added then
          vim.opt.runtimepath:append(course_dir)
        end
      end
    end
  end
end

write_server_name()
setup_course_snippets()

-- Spell check on the fly (Ctrl+L)
vim.keymap.set('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', opts)

-- LaTeX settings
vim.opt_local.spell = true
vim.opt_local.spelllang = { 'en_us', 'en_gb' }
vim.opt_local.conceallevel = 1
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

-- VimTeX viewer configuration
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1

-- Load lecture manager and reference generator
local lecture = require('lecture_manager')

-- Lecture manager keymaps using <localleader> (comma)
vim.keymap.set('n', '<localleader>Ln', lecture.new_lecture,
  { buffer = true, desc = 'New lecture' })
vim.keymap.set('n', '<localleader>Lc', lecture.compile_master,
  { buffer = true, desc = 'Compile master' })
vim.keymap.set('n', '<localleader>La', lecture.include_all_lectures,
  { buffer = true, desc = 'Include all lectures' })
vim.keymap.set('n', '<localleader>Ll', lecture.include_last_n_lectures,
  { buffer = true, desc = 'Include last N lectures' })
vim.keymap.set('n', '<localleader>Ls', lecture.list_lectures,
  { buffer = true, desc = 'List lectures' })


