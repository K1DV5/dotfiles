local default_shell = 'bash'
if not vim.fn.executable(default_shell) then
  default_shell = vim.api.nvim_get_option_value('shell', { scope = 'global' })
end

local default_height = 0.3

local M = {}

local function get_height(big)
  if vim.api.nvim_get_option_value('buftype', { buf = 0 }) ~= 'terminal' then
    local height = vim.api.nvim_win_get_height(0)
    if big then
      return height
    end
    return height * default_height
  end
  local height = vim.api.nvim_get_option_value('lines', { scope = 'global' }) - 2
  if big then
    return height
  end
  return math.floor(height * default_height)
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

local function toggle(big)
  -- big - boolean - the desired size of the pane
  -- work only if buffer is a normal file or a terminal
  local current_is_terminal = vim.api.nvim_get_option_value('buftype', { buf = 0 }) == 'terminal'
  if not vim.api.nvim_get_option_value('modifiable', { buf = 0 }) and not current_is_terminal then
    print("Not a file buffer, aborted")
    return true
  end
  local term_height = get_height(big)
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

local function get_existing(tbuflist, cmd, dir)
  local function filter_func(buf)
    local buf_cmd = vim.api.nvim_buf_get_var(buf, 'term_cmd')
    local buf_dir = vim.api.nvim_buf_get_var(buf, 'term_dir')
    return buf_cmd == cmd and buf_dir == dir
  end
  return vim.tbl_filter(filter_func, tbuflist)
end

local function clear_existing(tbuflist, cmd)
  -- only if the cmd has argumets, delete existing with the same cmd
  if string.find(cmd, ' ') then
    for _, buf in ipairs(tbuflist) do
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function M.open(opts) -- cmd: string, big: boolean, dir: string, send: string
  local opts = opts or {}
  local cmd = opts.cmd
  if cmd == nil then
    if toggle(opts.big) then
      return
    end
    cmd = default_shell
  elseif cmd == '' then
    cmd = default_shell
  end
  -- NEW TERMINAL
  if vim.api.nvim_get_option_value('buftype', { buf = 0 }) ~= 'terminal' and not go() then
    -- not in a terminal buffer and no terminal window to go to.
    -- prepare split window
    vim.api.nvim_command('belowright ' .. get_height(opts.big) .. ' split')
  end
  -- terminal buffer numbers like [1, 56, 78]
  -- same command terminal buffers
  local dir = opts and opts.dir
  if not dir then
    dir = vim.fn.fnamemodify('.', ':p')
  end
  local tbuflist = get_existing(get_terminals(), cmd, dir)
  local reuse = opts.send ~= nil and #tbuflist > 0
  if reuse then
    local buf = tbuflist[1]
    vim.api.nvim_win_set_buf(0, buf)
    local jobid = vim.api.nvim_buf_get_var(buf, 'terminal_job_id')
    vim.fn.chansend(jobid, opts.send .. '\r\n')
  else
    clear_existing(tbuflist, cmd)
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, buf)
    local jobid = vim.fn.jobstart(cmd, { cwd = dir, term = true })
    -- for future clears
    vim.api.nvim_buf_set_var(buf, 'term_cmd', cmd)
    vim.api.nvim_buf_set_var(buf, 'term_dir', dir)
  end
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
    M.open({
      cmd = opts.fargs[1],
      dir = opts.fargs[2],
      big = opts.fargs[3] and tonumber(opts.fargs[3]) > 0,
    })
  end, { complete = 'dir', nargs = '*' })

  local augroup = vim.api.nvim_create_augroup("term", {})
  vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    command = "setlocal nonumber norelativenumber nowrap",
  })
  -- open/close terminal pane
  vim.keymap.set('n', 't', M.open)
  -- open big terminal window / maximize
  vim.keymap.set('n', 'T', function() M.open({big = true}) end)
end

return M
