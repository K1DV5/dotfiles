local tabs = require'tabs'

local default_shell = vim.api.nvim_get_option('shell')
local default_height = 0.3

local function height(size)
	-- if the size is less than 1, it will be taken as the fraction of the file
	-- window
    local term_height
    size = size or default_height
	if size > 1 then
		term_height = size
	else
        if vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal' then
            term_height = math.floor((vim.api.nvim_get_option('lines') - 2) * size)
        else
            term_height = vim.api.nvim_win_get_height(0) * size 
        end
    end
	return term_height
end

-- get terminal buffers or windows
local function terminals(wins)
    local list
    local get_buffer = vim.api.nvim_win_get_buf
    if wins then  -- windows
        list = vim.api.nvim_list_wins()
    else  -- buffers
        list = vim.api.nvim_list_bufs()
        get_buffer = function(buf) return buf end
    end
    local function filter_func(item)
        local buffer = get_buffer(item)
        local is_terminal = vim.api.nvim_buf_get_option(buffer, 'buftype') == 'terminal'
        local is_listed = vim.api.nvim_buf_get_option(buffer, 'buflisted') == true
        return is_terminal and is_listed
    end
    return vim.tbl_filter(filter_func, list)
end

-- find and go to terminal pane, return success
local function go()
	-- terminal windows
	local tbufwins = terminals(true)
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
    local current_is_terminal = vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal'
	if not vim.api.nvim_buf_get_option(0, 'modifiable') and not current_is_terminal then
        print("Not a file buffer, aborted")
		return true
	end
	local term_height = height(size)
	-- if in terminal pane
	if current_is_terminal then
		if vim.api.nvim_win_get_height(0) < term_height then -- maximize
            vim.api.nvim_win_set_height(0, term_height)
		else
            vim.api.nvim_set_var('term_current_buf', vim.api.nvim_get_current_buf())
            vim.api.nvim_win_hide(0)
		end
        return true
    elseif go() then
        return true
    end
    -- terminal buffers
    local tbuflist = terminals()
    -- if last opened terminal is hidden but exists
    local current_buf = tabs.get_var('term_current_buf')
    local cmd_start = 'belowright ' .. term_height .. ' split +buffer\\ '
    if current_buf and vim.api.nvim_buf_is_loaded(current_buf) then
        vim.api.nvim_command(cmd_start .. current_buf)
    elseif vim.tbl_count(tbuflist) > 0 then -- choose one of the others
        vim.api.nvim_command(cmd_start .. tbuflist[1])
    else -- create a new one
        return
    end
    -- bring other terminal buffers into this window
    vim.api.nvim_win_set_var(0, 'tabs_buflist', tbuflist)
    return true
end

local buf_prefix = 'term://'

local function clear_existing(tbuflist, cmd, dir)
	-- if the cmd has argumets, delete existing with the same cmd
    if not string.find(cmd, ' ') then
        return
    end
    local cmp_dir = vim.fn.fnamemodify(dir, ':p')
    local cmp_start = string.len(buf_prefix) + 1
    for i, buf in pairs(tbuflist) do
        -- without the pid of the job
        local name = vim.fn.substitute(vim.api.nvim_buf_get_name(buf), '//\\d\\+:', '//', '')
        name = string.sub(name, cmp_start)
        local i_sep = string.find(name, '//')
        if i_sep == nil then
            goto continue
        end
        local t_dir = string.sub(name, 1, i_sep - 1)
        local t_cmd = string.sub(name, i_sep + 2)
        if vim.fn.fnamemodify(t_dir, ':p') == cmp_dir and t_cmd == cmd then
            vim.api.nvim_command('bdelete! ' .. buf)
        end
        ::continue::
    end
end

function term(cmd, dir)
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
	-- terminal buffer numbers like [1, 56, 78]
	local tbuflist = terminals()
    -- same command terminal buffers
    if not dir then
        dir = vim.fn.fnamemodify('.', ':p')
    end
    -- remove trailing backslashes from dir on windows
    dir = vim.fn.substitute(dir, '[\\/]\\+$', '', '')
    local buf_name = buf_prefix .. dir .. '//' .. cmd
    if vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal' or go() then
        -- open a new terminal
        vim.api.nvim_command('edit ' .. buf_name)
    else
        -- create a new terminal in split
        vim.api.nvim_command('belowright ' .. height(term_height) .. ' split ' .. buf_name)
        -- bring other terminal buffers into this window
        vim.api.nvim_win_set_var(0, 'tabs_buflist', tbuflist)
        if cmd == 1 then
            local h = height(term_height)
            if vim.api.nvim_win_get_height(0) < h then -- maximize
                vim.api.nvim_command('resize ' .. h)
            end
        end
    end
    clear_existing(tbuflist, cmd, dir)
    tabs_reload()
end

function clear_terms()
    for i, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
            vim.api.nvim_buf_delete(buf, {force = true})
        end
    end
end

vim.api.nvim_create_user_command("T", function(opts)
    if vim.tbl_count(opts.fargs) == 0 then
        opts.fargs = {''}
    end
    term(unpack(opts.fargs))
end, {complete = 'shellcmd', nargs = '*'})

vim.api.nvim_create_augroup("term", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
    group = "term",
    command = "setlocal nonumber norelativenumber nowrap",
})
