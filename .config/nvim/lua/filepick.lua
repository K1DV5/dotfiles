local M = {}

local cmd = "git ls-files -c -o --exclude-standard"

local function trim(str)
  return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

local function get_file_completion(arg_lead, cmdline, cur_pos)
  local cmdout = trim(io.popen(cmd):read("*a"))
  return cmdout:split("\n")
end

local function cmd_handler(opts)
  local arg = trim(opts.args)
  if arg ~= "" then
    vim.cmd.edit({args = {arg}})
  end
end

local assist_cmds = {FilePick = true}

function M.blink_check_assist(ctx)
  return assist_cmds[ctx.line:split(" ")[1]] or false
end

function M.setup()
  vim.api.nvim_create_user_command(
    "FilePick",
    cmd_handler,
    { complete = get_file_completion, nargs = '*', force = true }
  )
  vim.keymap.set('n', '-', function () vim.api.nvim_input(':FilePick ') end)
end

return M
