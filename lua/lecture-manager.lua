local M = {}

-- Get the course directory from current file
local function get_course_dir()
  local current_file = vim.fn.expand('%:p')
  local school_dir = vim.fn.expand('~/School/')
  
  if vim.startswith(current_file, school_dir) then
    local relative_path = current_file:sub(#school_dir + 1)
    local course_path = relative_path:match('^([^/]+/[^/]+)/')
    if course_path then
      return school_dir .. course_path
    end
  end
  return nil
end

-- Get next lecture number
local function get_next_lecture_number(course_dir)
  local handle = io.popen('ls -1 ' .. course_dir .. '/notes/lec_*.tex 2>/dev/null | wc -l')
  local count = handle:read("*a")
  handle:close()
  return tonumber(count) + 1
end

-- Update master.tex to include lectures
local function update_master(course_dir, lecture_nums)
  local master_path = course_dir .. '/master.tex'
  local file = io.open(master_path, 'r')
  if not file then
    vim.notify('master.tex not found in ' .. course_dir, vim.log.levels.ERROR)
    return false
  end
  
  local content = file:read('*all')
  file:close()
  
  -- Build the lecture inputs
  local inputs = ''
  for _, num in ipairs(lecture_nums) do
    inputs = inputs .. string.format('    \\input{notes/lec_%02d.tex}\n', num)
  end
  
  -- Replace content between markers
  local new_content = content:gsub(
    '(%s*%% start lectures\n).-(%% end lectures)',
    '%1' .. inputs .. '    %2'
  )
  
  -- Write back
  file = io.open(master_path, 'w')
  if file then
    file:write(new_content)
    file:close()
    return true
  end
  return false
end

-- Create a new lecture
function M.new_lecture()
  local course_dir = get_course_dir()
  if not course_dir then
    vim.notify('Not in a course directory', vim.log.levels.ERROR)
    return
  end
  
  local lecture_num = get_next_lecture_number(course_dir)
  
  -- Prompt for lecture title
  vim.ui.input({ prompt = 'Lecture title: ' }, function(title)
    if not title then return end
    
    -- Create lecture file
    local lecture_file = string.format('%s/notes/lec_%02d.tex', course_dir, lecture_num)
    local date = os.date('%a %d %b %H:%M')
    local content = string.format('\\lecture{%d}{%s}{%s}\n\n', lecture_num, date, title)
    
    local file = io.open(lecture_file, 'w')
    if file then
      file:write(content)
      file:close()
      
      -- Update master.tex to include last 2 lectures
      local lectures_to_include = {}
      if lecture_num > 1 then
        table.insert(lectures_to_include, lecture_num - 1)
      end
      table.insert(lectures_to_include, lecture_num)
      
      if update_master(course_dir, lectures_to_include) then
        vim.notify('Created lecture ' .. lecture_num, vim.log.levels.INFO)
        -- Open the new lecture file
        vim.cmd('edit ' .. lecture_file)
      end
    else
      vim.notify('Failed to create lecture file', vim.log.levels.ERROR)
    end
  end)
end

-- Compile master.tex
function M.compile_master()
  local course_dir = get_course_dir()
  if not course_dir then
    vim.notify('Not in a course directory', vim.log.levels.ERROR)
    return
  end
  
  local master_path = course_dir .. '/master.tex'
  vim.notify('Compiling master.tex...', vim.log.levels.INFO)
  
  -- Use latexmk for compilation
  vim.fn.jobstart(
    string.format('cd %s && latexmk -pdf -interaction=nonstopmode master.tex', course_dir),
    {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify('Compilation successful!', vim.log.levels.INFO)
        else
          vim.notify('Compilation failed!', vim.log.levels.ERROR)
        end
      end
    }
  )
end

-- Include all lectures in master.tex
function M.include_all_lectures()
  local course_dir = get_course_dir()
  if not course_dir then
    vim.notify('Not in a course directory', vim.log.levels.ERROR)
    return
  end
  
  -- Get all lecture files
  local handle = io.popen('ls -1 ' .. course_dir .. '/notes/lec_*.tex 2>/dev/null | sort')
  local lectures = {}
  
  for filename in handle:lines() do
    local num = filename:match('lec_(%d+)%.tex')
    if num then
      table.insert(lectures, tonumber(num))
    end
  end
  handle:close()
  
  if #lectures > 0 then
    update_master(course_dir, lectures)
    vim.notify('Included all ' .. #lectures .. ' lectures', vim.log.levels.INFO)
  else
    vim.notify('No lectures found', vim.log.levels.WARN)
  end
end

-- Include last N lectures
function M.include_last_n_lectures()
  vim.ui.input({ prompt = 'Number of lectures to include: ', default = '2' }, function(input)
    if not input then return end
    
    local n = tonumber(input)
    if not n then
      vim.notify('Invalid number', vim.log.levels.ERROR)
      return
    end
    
    local course_dir = get_course_dir()
    if not course_dir then
      vim.notify('Not in a course directory', vim.log.levels.ERROR)
      return
    end
    
    -- Get all lecture numbers
    local handle = io.popen('ls -1 ' .. course_dir .. '/notes/lec_*.tex 2>/dev/null | sort')
    local all_lectures = {}
    
    for filename in handle:lines() do
      local num = filename:match('lec_(%d+)%.tex')
      if num then
        table.insert(all_lectures, tonumber(num))
      end
    end
    handle:close()
    
    -- Take last n lectures
    local lectures_to_include = {}
    local start_idx = math.max(1, #all_lectures - n + 1)
    for i = start_idx, #all_lectures do
      table.insert(lectures_to_include, all_lectures[i])
    end
    
    if #lectures_to_include > 0 then
      update_master(course_dir, lectures_to_include)
      vim.notify('Included last ' .. #lectures_to_include .. ' lectures', vim.log.levels.INFO)
    end
  end)
end

-- List all lectures
function M.list_lectures()
  local course_dir = get_course_dir()
  if not course_dir then
    vim.notify('Not in a course directory', vim.log.levels.ERROR)
    return
  end
  
  -- Get all lecture files and parse them
  local lectures = {}
  local handle = io.popen('ls -1 ' .. course_dir .. '/notes/lec_*.tex 2>/dev/null | sort')
  
  for filepath in handle:lines() do
    local file = io.open(filepath, 'r')
    if file then
      local first_line = file:read('*line')
      file:close()
      
      -- Parse \lecture{num}{date}{title}
      local num, date, title = first_line:match('\\lecture{(%d+)}{([^}]*)}{([^}]*)}')
      if num then
        table.insert(lectures, {
          number = tonumber(num),
          date = date,
          title = title,
          file = filepath
        })
      end
    end
  end
  handle:close()
  
  -- Show in a selection menu
  if #lectures > 0 then
    local items = {}
    for _, lec in ipairs(lectures) do
      table.insert(items, string.format('Lec %02d: %s (%s)', lec.number, lec.title, lec.date))
    end
    
    vim.ui.select(items, { prompt = 'Select lecture:' }, function(_, idx)
      if idx then
        vim.cmd('edit ' .. lectures[idx].file)
      end
    end)
  else
    vim.notify('No lectures found', vim.log.levels.WARN)
  end
end

return M
