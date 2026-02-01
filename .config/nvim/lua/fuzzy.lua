-- $ nvim -l %f

local M = {}

local cmd = "git ls-files -c -o --exclude-standard --deduplicate"
local ignore = '\\( -path ./node_modules -o -path ./.git \\) -prune -o '
local find_f = "-type f -printf '%P\\n'"
local find_d = "-type d -printf '%P/\\n'"
local cmd_non_git = "find . " .. ignore .. find_f
local cmd_non_git_all = "find . -mindepth 1 " .. ignore .. find_f .. " -or " .. find_d
local cmd_non_git_dirs = 'find . -mindepth 1 ' .. ignore .. find_d

local manifest = {
  FilePick = {
    cmd = cmd,
    key = '-',
    handle = function(arg) vim.cmd.edit({args = {arg}}) end,
  },
  FilePickCreate = {
    cmd = cmd_non_git_dirs,
    key = '1-',
    handle = function(dir)
      local path = vim.fn.input('In: ', dir, 'dir')
      vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), "p")
      vim.cmd.edit({args = {path}}) 
    end
  },
  FilePickRename = {
    cmd = cmd_non_git_all,
    key = '2-',
    handle = function(path)
      local dest = vim.fn.input('To: ', path, 'dir')
      vim.fn.mkdir(vim.fn.fnamemodify(dest, ':h'), "p")
      vim.fn.rename(path, dest)
      if string.sub(path, -1) == '/' then
        return
      end
      local currb = vim.fn.bufnr(path)
      if currb ~= -1 then
        vim.api.nvim_buf_set_name(currb, dest)
      end
    end
  },
  FilePickCopy = {
    cmd = cmd_non_git_all,
    key = '3-',
    handle = function(path)
      vim.uv.fs_copyfile(path, vim.fn.input('To: ', path, 'file'))
    end
  },
  FilePickDelete = {
    cmd = cmd_non_git_all,
    key = '0-',
    handle = function(path)
      if vim.fn.confirm("Delete " .. path .. "?", "&Yes\n&No") == 1 then
        vim.fn.delete(path, "rf")
      end
    end
  },
  ['AutoSession restore'] = {
    key = '_',
  }
}

local function get_file_completion(arg_lead, cmdline, cur_pos)
  local command = (manifest[vim.split(cmdline, " ")[1]] or {cmd = cmd_non_git}).cmd
  local cmdout = io.popen(command):read("*a")
  if cmdout == "" and command ~= cmd_non_git then
    cmdout = io.popen(cmd_non_git):read("*a")
  end
  return vim.split(vim.trim(cmdout), "\n")
end

local function cmd_handler(opts)
  local arg = vim.trim(opts.args)
  local conf = manifest[opts.name]
  if conf then
    conf.handle(arg)
  end
end

function M.blink_check_assist(ctx)
  local base_cmd = ''
  for _, word in ipairs(vim.split(ctx.line, " ")) do
    if base_cmd == '' then
      base_cmd = word
    else
      base_cmd = base_cmd .. " " .. word
    end
    if manifest[base_cmd] ~= nil then
      return true
    end
  end
  return false
end

function M.setup()
  for cmd, conf in pairs(manifest) do
    if cmd_handler ~= nil then
      vim.api.nvim_create_user_command(
        cmd,
        cmd_handler,
        { complete = get_file_completion, nargs = '*', force = true }
      )
    end
    vim.keymap.set('n', conf.key, function () vim.api.nvim_input(':' .. cmd .. ' ') end)
  end
end

return M
