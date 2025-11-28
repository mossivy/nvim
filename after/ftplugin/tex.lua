-- LaTeX-specific settings for note-taking workflow
local opts = { buffer = true, silent = true }

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
    -- Extract course directory (e.g., ~/School/2024-2025/Math301/)
    local relative_path = current_file:sub(#school_dir + 1)
    local course_path = relative_path:match('^([^/]+/[^/]+)/')
    
    if course_path then
      local course_dir = school_dir .. course_path
      -- Add to runtimepath if it exists and isn't already added
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
          -- Optional: print notification
          -- print('Loaded course snippets from: ' .. course_path)
        end
      end
    end
  end
end

-- Call setup functions when opening tex files
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

-- VimTeX viewer configuration for Skim on macOS
vim.g.vimtex_view_method = 'skim'
-- Optional: Enable forward search when compiling
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1
