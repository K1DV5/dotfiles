local devicons = require'nvim-web-devicons'

local M = {}

function M.get_var(name, scope, id)
    local args = {vim.api.nvim_buf_get_var}
    if scope == 'w' then  -- w:
        args[1] = vim.api.nvim_win_get_var
        if id == nil then
            table.insert(args, 0)
        else
            table.insert(args, id)
        end
    elseif id == nil then
        if scope == nil then  -- g:
            args[1] = vim.api.nvim_get_var
        else  -- b:
            table.insert(args, 0)
        end
    else
        table.insert(args, id)
    end
    table.insert(args, name)
    local ok, value = pcall(unpack(args))
    if ok then
        return value
    end
end

local function get_alt_buf(win)  -- get the alternate buffer for the given window
    local bufs = M.get_var('tabs_buflist', 'w', win) or {}
    local l_bufs = vim.tbl_count(bufs)
    if l_bufs < 2 then
        return
    end
    local alt = M.get_var('tabs_alt_file', 'w', win)
    local current = vim.api.nvim_win_get_buf(win)
    if vim.tbl_contains(bufs, alt) and alt ~= current then
        return alt
    end
    for i, buf in pairs(bufs) do
        if buf == current then
            if i == l_bufs then -- last, return first
                return bufs[1]
            end
            return bufs[i + 1]  -- next
        end
    end
end

local function get_alt_win(current)
    local alt_win = M.get_var('tabs_alt_win')
    local wins = vim.api.nvim_list_wins()
    if vim.tbl_contains(wins, alt_win) and current ~= alt_win then
        return alt_win
    end
    local l_wins = vim.tbl_count(wins)
    if l_wins < 2 then
        return
    end
    -- find the next one
    for i, win in pairs(wins) do
        if win == current then
            if i == l_wins then -- last, return first
                return wins[1]
            end
            return wins[i + 1]  -- next
        end
    end
end


function M.get_icon()
    if vim.api.nvim_buf_get_option(0, 'buftype') == 'terminal' then
        local icon, hi = devicons.get_icon('', 'terminal')
        return {icon, hi}
    end
    local fname = vim.fn.expand('%')
    local ext = vim.fn.expand('%:e')
    local icon, hi = devicons.get_icon(fname, ext)
    if icon == nil then
        return {'', 'Normal'}
    end
    return {icon, hi}
end

function M.status_text()
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.fn.bufwinid(bufnr)
    local bufs = vim.api.nvim_win_get_var(win, 'tabs_buflist') or {bufnr}
    local text = '%<%#StatuslineNC#'
    local is_current_win = vim.api.nvim_get_current_win() == win
    local alt = get_alt_buf(win)  -- alternate buffer for the current win
    for i, buf in pairs(bufs) do
        local name = vim.api.nvim_buf_get_name(buf)
        if name then
            name = vim.fn.fnamemodify(name, ':t')
        else
            name = '[No name]'
        end
        if buf == bufnr then  -- current buf
            local icon
            if is_current_win then
                local iconhl = M.get_icon()
                local hl_icon = '%#' .. iconhl[2] .. '#'
                icon = hl_icon .. ' ' .. iconhl[1] .. ' '
            else
                icon = '%#Normal# %{v:lua.require("tabs").get_icon()[1]} '
            end
            text = text .. icon .. '%#Normal#' .. name .. '%m %#StatuslineNC#'
        else
            local num
            if not is_current_win then
                num = ''
            elseif buf == alt then
                num = '# '
            else
                num = i .. ':'
            end
            text = text .. ' ' .. num .. name .. ' '
        end
    end
    return text
end

function M.reload()
    local current_buf = vim.api.nvim_get_current_buf()
    local win_bufs = M.get_var('tabs_buflist', 'w')
    if win_bufs then
        local win_bufs_new = {}
        local current_included = false
        for _, buf in pairs(win_bufs) do
            if vim.fn.buflisted(buf) ~= 0 then
                table.insert(win_bufs_new, buf)
                if buf == current_buf then
                    current_included = true
                end
            end
        end
        if not current_included and vim.fn.buflisted(current_buf) ~= 0 then  -- maybe added
            table.insert(win_bufs_new, current_buf)
        end
        vim.api.nvim_win_set_var(0, 'tabs_buflist', win_bufs_new)
    elseif vim.api.nvim_buf_get_name(current_buf) == '' and not vim.api.nvim_buf_get_option(current_buf, 'modified') then -- empty
        vim.api.nvim_win_set_var(0, 'tabs_buflist', {})
    else
        vim.api.nvim_win_set_var(0, 'tabs_buflist', {current_buf})
    end
end

function M.all_buffers()
    local win_bufs_new = {}
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        local empty = vim.api.nvim_buf_get_name(buf) == '' and not M.get_var('modified', 'b', buf)
        if vim.api.nvim_buf_is_valid(buf) and not empty then
            table.insert(win_bufs_new, buf)
        end
    end
    vim.api.nvim_win_set_var(0, 'tabs_buflist', win_bufs_new)
    M.reload()
end

function M.go(where, win)
    -- go to the specified buffer or win
    if win then
        if where == 0 then  -- jump to alt
            vim.api.nvim_set_current_win(get_alt_win(vim.api.nvim_get_current_win()))
        else
            vim.api.nvim_set_current_win(where)
        end
    else  -- buffer
        local last = vim.api.nvim_get_current_buf()
        if where == 0 then  -- alt
            local alt = get_alt_buf(vim.api.nvim_get_current_win())
            if alt then
                vim.api.nvim_set_current_buf(alt)
            end
        else  -- to is an index (shown on the bar)
            local bufs = M.get_var('tabs_buflist', 'w')
            if where <= vim.tbl_count(bufs) then
                vim.api.nvim_set_current_buf(bufs[where])
            else
                print('No buffer at ' .. where)
            end
        end
        local current_buf = vim.api.nvim_get_current_buf()
        if last ~= current_buf then
            vim.api.nvim_win_set_var(0, 'tabs_alt_file', last)
        else
            vim.api.nvim_win_set_var(0, 'tabs_alt_file', current_buf)
        end
    end
end

function M.close()
    -- close current tab
    if vim.api.nvim_buf_get_option(0, 'modified') then
        print("File modified")
        return
    end
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    local alt = get_alt_buf(0)
    local current = vim.api.nvim_get_current_buf()
    if alt then
        vim.api.nvim_set_current_buf(alt)
    end
    -- vim.api.nvim_buf_delete(current, {force = buftype == 'terminal'})
    local cmd = 'bdelete'
    if buftype == 'terminal' then
        cmd = cmd .. '!'
    end
    vim.api.nvim_command(cmd .. ' ' .. current)
    M.reload()
end

function M.setup()
    local augroup = vim.api.nvim_create_augroup("tabs", {})
    vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile', 'BufLeave', 'FileType', 'TermOpen'}, {
        group = augroup,
        callback = M.reload,
    })
    vim.api.nvim_create_autocmd('WinLeave', {
        group = augroup,
        callback = function() vim.api.nvim_set_var('tabs_alt_win', vim.api.nvim_get_current_win()) end,
    })
end

return M
