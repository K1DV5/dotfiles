local devicons = require 'nvim-web-devicons'

local M = {}

local force_alone_ft = {
    'gitcommit',
}

function M.get_sibling_buffers(bufnr)
  local filetype = vim.api.nvim_get_option_value('filetype', {buf = bufnr})
  if vim.tbl_contains(force_alone_ft, filetype) then
    return {bufnr}
  end
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
  local siblings = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf == bufnr then
      table.insert(siblings, buf)
      goto continue
    end
    if vim.fn.buflisted(buf) == 0 then
      goto continue
    end
    local buft = vim.api.nvim_get_option_value('buftype', { buf = buf })
    if buft ~= buftype then
      goto continue
    end
    local modified = vim.api.nvim_get_option_value('modified', { buf = buf })
    local empty = not modified and vim.api.nvim_buf_get_name(buf) == ''
    if vim.api.nvim_buf_is_valid(buf) and not empty then
      table.insert(siblings, buf)
    end
    ::continue::
  end
  return siblings
end

local function get_alt(item, siblings, vimalt)
  local bufindex = 1
  local altindex = -1
  for i, sibling in ipairs(siblings) do
    if sibling == item then
      bufindex = i
    elseif sibling == vimalt then
      altindex = i
    end
  end
  if altindex ~= -1 then   -- alt among siblings
    return vimalt
  end
  if #siblings == bufindex then
    return siblings[bufindex - 1]
  end
  return siblings[bufindex + 1]
end

local function get_alt_buf(buf, bufs)
  if #bufs < 2 then
    return
  end
  local alt = vim.fn.bufnr('#')
  return get_alt(buf, bufs, alt)
end

local function get_alt_win()
  local wins = vim.api.nvim_list_wins()
  if #wins < 2 then
    return
  end
  local win = vim.api.nvim_get_current_win()
  local alt = vim.fn.win_getid(vim.fn.winnr('#'))
  return get_alt(win, wins, alt)
end

local function get_icon(buf, name)
  if vim.api.nvim_get_option_value('buftype', { buf = buf }) == 'terminal' then
    local icon, hi = devicons.get_icon('', 'terminal')
    return icon, hi
  end
  local ext = vim.fn.fnamemodify(name, ':e')
  local icon, hi = devicons.get_icon(name, ext)
  if icon == nil then
    return '', 'Normal'
  end
  return icon, hi
end

function M.status_text_bufs()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufs = M.get_sibling_buffers(bufnr)
  local text = '%<%#StatuslineNC#'
  local alt = get_alt_buf(bufnr, bufs)   -- alternate buffer for the current win
  for i, buf in pairs(bufs) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name then
      name = vim.fn.fnamemodify(name, ':t')
    else
      name = '[unnamed]'
    end
    local icon, highlight = get_icon(buf, name)
    if buf == bufnr then     -- current buf
      icon = string.format('%%#%s# %s ', highlight, icon)
      text = text .. string.format('%s%%#%s#%s%%h%%w%%m%%r %%#StatuslineNC#', icon, highlight, name)
    else
      name = vim.fn.fnamemodify(name, ':t:r')
      local num
      if buf == alt then
        num = '# '
      else
        num = i .. ':'
      end
      text = text .. string.format(' %s%s.%%-01.(%s%%) ', num, icon, name)
    end
  end
  return text
end

function M.status_text()
  local win = vim.api.nvim_get_current_win()
  local stlwin = vim.g.statusline_winid
  if win == stlwin then
    local text = '%%#FocusedSymbol# %s '
    text = text:format(vim.api.nvim_get_mode().mode:upper())
    return text .. M.status_text_bufs() .. '%#FocusedSymbol#'
  end
  local text = '%%#Statusline# '
  local alt_win = get_alt_win()
  if stlwin == alt_win then
    text = (text .. '%s '):format('#')
  else
    text = (text .. '%d '):format(vim.fn.win_id2win(stlwin))
  end
  text = text .. '%#StatuslineNC# %<%f %h%w%m%r'
  return text
end

function M.go_buf(where)
  local last = vim.api.nvim_get_current_buf()
  local bufs = M.get_sibling_buffers(0)
  if where == 0 then   -- alt
    local alt = get_alt_buf(last, bufs)
    if alt then
      vim.api.nvim_set_current_buf(alt)
    end
  else   -- to is an index (shown on the bar)
    if where <= vim.tbl_count(bufs) then
      vim.api.nvim_set_current_buf(bufs[where])
    else
      print('No buffer at ' .. where)
    end
  end
end

function M.go_win(where)
  if where > 0 then                     -- jump to alt
    where = vim.fn.win_getid(where)     -- convert to id
    vim.api.nvim_set_current_win(where)
    return
  end
  local alt_win = get_alt_win()
  if alt_win ~= nil then
    vim.api.nvim_set_current_win(alt_win)
  end
end

function M.close()
  -- close current tab
  if vim.api.nvim_get_option_value('modified', { buf = 0 }) then
    print("File modified")
    return
  end
  local buftype = vim.api.nvim_get_option_value('buftype', { buf = 0 })
  local current = vim.api.nvim_get_current_buf()
  local bufs = M.get_sibling_buffers(current)
  local alt = get_alt_buf(current, bufs)
  local wins = vim.api.nvim_list_wins()
  if not alt then
    if #wins == 1 then
      vim.cmd.bdelete { count = current, bang = buftype == 'terminal' }
      return
    end
    vim.api.nvim_win_close(0, false)
    local next = vim.api.nvim_get_current_buf()
    if next ~= current and vim.api.nvim_buf_is_valid(current) then
      vim.cmd.bdelete { count = current, bang = buftype == 'terminal' }
    end
    return
  end
  vim.api.nvim_set_current_buf(alt)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_buf(win) == current then
      return
    end
  end
  vim.cmd.bdelete { count = current, bang = buftype == 'terminal' }
end

function M.setup()
  -- using tab for switching buffers
  vim.keymap.set('n', '<tab>', function() M.go_buf(vim.v.count) end)
  -- switch windows using `
  vim.keymap.set('n', '`', function() M.go_win(vim.v.count) end)
  -- closing current buffer
  vim.keymap.set({ 'n', 't' }, '<leader>x', M.close)
  -- set statusline
  vim.opt.statusline = '%!v:lua.require("tabs").status_text()'
end

return M
