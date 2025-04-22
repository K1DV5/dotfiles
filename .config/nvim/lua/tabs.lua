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

local diag_hls = { 'Error', 'Warn', 'Info', 'Hint' }
local inactive_hl = '%#BufferInactive#'
local fname_len_limit = 24
local low_wid_inactive = 15

local function diagnostic_counts()
  local diag_status = ''
  local counts = vim.diagnostic.count(0)
  for _, sev in ipairs(diag_hls) do
    local count = counts[vim.diagnostic.severity[sev:upper()]]
    if count ~= nil then
      diag_status = diag_status .. ('%%#DiagnosticSign%s# %d'):format(sev, count)
    end
  end
  return diag_status
end

function M.status_text_bufs()
  local bufnr = vim.api.nvim_get_current_buf()
  local bufs = M.get_sibling_buffers(bufnr)
  local text = inactive_hl
  local alt = get_alt_buf(bufnr, bufs) -- alternate buffer for the current win
  local winwid_inactive = vim.api.nvim_win_get_width(0) - fname_len_limit
  local maxwid_inactive = math.floor(winwid_inactive / #bufs)
  local names = {}
  local name_occurences = {}
  for i, buf in pairs(bufs) do
    local name = vim.api.nvim_buf_get_name(buf)
    local tail
    if not name then
      name = '[unnamed]'
      tail = name
    else
      tail = vim.fn.fnamemodify(name, ':t')
    end
    name_occurences[tail] = (name_occurences[tail] or 0) + 1
    names[i] = { tail = tail, full = name }
  end
  for i, buf in pairs(bufs) do
    local name = names[i].full
    local sname = names[i].tail
    local icon, highlight = get_icon(buf, name)
    if buf == bufnr then -- current buf
      local maxwid_active = fname_len_limit
      if name_occurences[sname] == 1 or maxwid_inactive < low_wid_inactive then
        name = sname
      else
        local dir = vim.fn.fnamemodify(name, ':.:h:t')
        if dir == '.' then
          name = sname
        else
          name = dir .. '/' .. sname
          if #name < fname_len_limit then
            maxwid_active = #name + 1
          end
        end
      end
      icon = string.format('%%#%s# %s ', highlight, icon)
      local format = '%s%%-01.%d(%%#%s#%s%%)%%h%%w%%m%%r%s %s'
      text = text .. format:format(icon, maxwid_active, highlight, name, diagnostic_counts(), inactive_hl)
    else
      local num
      if buf == alt then
        num = '# '
      else
        num = i .. ':'
      end
      local exticon = ''
      if maxwid_inactive < low_wid_inactive then
        name = vim.fn.fnamemodify(sname, ':r')
        exticon = '.' .. icon
      else
        name = sname
      end
      text = text .. string.format(' %s%%-.%d(%s%s%%) ', num, maxwid_inactive, name, exticon)
    end
  end
  return text
end

function M.status_text()
  local win = vim.api.nvim_get_current_win()
  local stlwin = vim.g.statusline_winid
  if win == stlwin then
    local text = '%%#FocusedSymbol# %s %%<'
    text = text:format(vim.api.nvim_get_mode().mode:upper())
    return text .. M.status_text_bufs() .. '%#FocusedSymbol#%=%S '
  end
  local text = '%%#StatuslineNC# '
  local alt_win = get_alt_win()
  if stlwin == alt_win then
    text = (text .. '%s '):format('#')
  else
    text = (text .. '%d '):format(vim.fn.win_id2win(stlwin))
  end
  text = text .. ' %<%f %h%w%m%r'
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
  vim.cmd'hi! link Statusline Normal'
  vim.o.showcmdloc = 'statusline'
  vim.o.statusline = '%!v:lua.require("tabs").status_text()'
end

return M
