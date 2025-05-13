local M = {}

local cmd = "git ls-files -c -o --exclude-standard"

local function get_file_completion(arg_lead, cmdline, cur_pos)
  local cmdout = vim.trim(io.popen(cmd):read("*a"))
  return vim.split(cmdout, "\n")
end

local function cmd_handler(opts)
  local arg = vim.trim(opts.args)
  if arg ~= "" then
    vim.cmd.edit({args = {arg}})
  end
end

local assist_cmds = {FilePick = true}

function M.blink_check_assist(ctx)
  return assist_cmds[vim.split(ctx.line, " ")[1]] or false
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
