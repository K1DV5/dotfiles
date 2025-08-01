local default_shell = 'bash'
if not vim.fn.executable(default_shell) then
  default_shell = vim.api.nvim_get_option_value('shell', { scope = 'global' })
end

local default_height = 0.3

local M = {}

local function get_height(size)
  -- if the size is less than 1, it will be taken as the fraction of the file
  -- window
  local term_height
  size = size or default_height
  if size > 1 then
    term_height = size
  else
    if vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'terminal' then
      local total_win_lines = vim.api.nvim_get_option_value('lines', { scope = 'global' })
      term_height = math.floor((total_win_lines - 2) * size)
    else
      term_height = vim.api.nvim_win_get_height(0) * size
    end
  end
  return term_height
end

-- get terminal buffers or windows
local function get_terminals(get_windows)
  local list
  local get_buffer = vim.api.nvim_win_get_buf
  if get_windows then
    list = vim.api.nvim_list_wins()
  else
    list = vim.api.nvim_list_bufs()
    get_buffer = function(buf) return buf end
  end
  local function filter_func(item)
    local buffer = get_buffer(item)
    local is_terminal = vim.api.nvim_get_option_value('buftype', { buf = buffer }) == 'terminal'
    local is_listed = vim.api.nvim_get_option_value('buflisted', { buf = buffer }) == true
    return is_terminal and is_listed
  end
  return vim.tbl_filter(filter_func, list)
end

-- find and go to terminal pane, return success
local function go()
  -- terminal windows
  local tbufwins = get_terminals(true)
  -- if there is a terminal window
  if vim.tbl_count(tbufwins) > 0 then
    -- go to that window
    vim.api.nvim_set_current_win(tbufwins[1])
    return true
  end
  return false
end

local function toggle(size)
  -- size - number | float - the desired size of the pane
  -- work only if buffer is a normal file or a terminal
  local current_is_terminal = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'terminal'
  if not vim.api.nvim_get_option_value('modifiable', { buf = 0 }) and not current_is_terminal then
    print("Not a file buffer, aborted")
    return true
  end
  local term_height = get_height(size)
  -- if in terminal pane
  if current_is_terminal then
    if vim.api.nvim_win_get_height(0) < term_height then     -- maximize
      vim.api.nvim_win_set_height(0, term_height)
    else
      vim.g.term_current_buf = vim.api.nvim_get_current_buf()
      vim.api.nvim_win_hide(0)
    end
    return true
  elseif go() then
    return true
  end
  -- terminal buffers
  local tbuflist = get_terminals()
  -- if last opened terminal is hidden but exists
  local current_buf = vim.g.term_current_buf
  local cmd_start = 'belowright ' .. term_height .. ' split +buffer\\ '
  if current_buf and vim.api.nvim_buf_is_loaded(current_buf) then
    vim.api.nvim_command(cmd_start .. current_buf)
  elseif vim.tbl_count(tbuflist) > 0 then   -- choose one of the others
    vim.api.nvim_command(cmd_start .. tbuflist[1])
  else                                      -- create a new one
    return
  end
  return true
end

local function clear_existing(tbuflist, cmd, dir)
  -- if the cmd has argumets, delete existing with the same cmd
  if not string.find(cmd, ' ') then
    return
  end
  for _, buf in pairs(tbuflist) do
    local buf_cmd = vim.api.nvim_buf_get_var(buf, 'term_cmd')
    local buf_dir = vim.api.nvim_buf_get_var(buf, 'term_dir')
    if buf_cmd == cmd and buf_dir == dir then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function M.open(cmd, dir)
  -- cmd - string | number - the cmd name or the desired win height
  local term_height = default_height
  if type(cmd) == 'number' or cmd == nil then
    if toggle(cmd) then
      return
    end
    term_height = cmd or term_height
    cmd = default_shell
  elseif cmd == '' then
    cmd = default_shell
  end
  -- NEW TERMINAL
  if vim.api.nvim_get_option_value('buftype', { buf = 0 }) ~= 'terminal' and not go() then
    -- not in a terminal buffer and no terminal window to go to.
    -- prepare split window
    vim.api.nvim_command('belowright ' .. get_height(term_height) .. ' split')
    if cmd == 1 then
      local h = get_height(term_height)
      if vim.api.nvim_win_get_height(0) < h then       -- maximize
        vim.api.nvim_command('resize ' .. h)
      end
    end
  end
  -- terminal buffer numbers like [1, 56, 78]
  local tbuflist = get_terminals()
  -- same command terminal buffers
  if not dir then
    dir = vim.fn.fnamemodify('.', ':p')
  end
  -- avoid buffer modified error
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_win_set_buf(0, buf)
  vim.fn.jobstart(cmd, { cwd = dir, term = true })
  clear_existing(tbuflist, cmd, dir)
  -- for future clears
  vim.api.nvim_buf_set_var(buf, 'term_cmd', cmd)
  vim.api.nvim_buf_set_var(buf, 'term_dir', dir)
end

function M.clear()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function M.setup()
  vim.api.nvim_create_user_command("T", function(opts)
    if vim.tbl_count(opts.fargs) == 0 then
      opts.fargs = { '' }
    end
    M.open(unpack(opts.fargs))
  end, { complete = 'dir', nargs = '*' })

  local augroup = vim.api.nvim_create_augroup("term", {})
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    command = "setlocal nonumber norelativenumber nowrap",
  })
  -- open/close terminal pane
  vim.keymap.set('n', 't', M.open)
  -- open big terminal window / maximize
  vim.keymap.set('n', 'T', function() M.open(1) end)
end

return M
