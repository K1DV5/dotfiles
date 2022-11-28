local devicons = require'nvim-web-devicons'
local tabs = require'tabs'

function get_icon()
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

function tabs_status_text()
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.fn.bufwinid(bufnr)
    local bufs = vim.api.nvim_win_get_var(win, 'tabs_buflist') or {bufnr}
    local text = '%<%#StatuslineNC#'
    local is_current_win = vim.api.nvim_get_current_win() == win
    local alt = tabs.get_alt_buf(win)  -- alternate buffer for the current win
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
                local iconhl = get_icon()
                local hl_icon = '%#' .. iconhl[2] .. '#'
                icon = hl_icon .. ' ' .. iconhl[1] .. ' '
            else
                icon = '%#Normal# %{v:lua.get_icon()[1]} '
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

function tabs_reload()
    local current_buf = vim.api.nvim_get_current_buf()
    local win_bufs = tabs.get_var('tabs_buflist', 'w')
    if win_bufs then
        local win_bufs_new = {}
        local current_included = false
        for i, buf in pairs(win_bufs) do
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

function tabs_all_buffers()
    local win_bufs = tabs.get_var('tabs_buflist', 'w')
    local win_bufs_new = {}
    for i, buf in pairs(vim.api.nvim_list_bufs()) do
        local empty = vim.api.nvim_buf_get_name(buf) == '' and not tabs.get_var('modified', 'b', buf)
        if vim.api.nvim_buf_is_valid(buf) and not empty then
            table.insert(win_bufs_new, buf)
        end
    end
    vim.api.nvim_win_set_var(0, 'tabs_buflist', win_bufs_new)
    tabs_reload()
end

function tabs_go(where, win)
    -- go to the specified buffer or win
    if win then
        if where == 0 then  -- jump to alt
            vim.api.nvim_set_current_win(tabs.get_alt_win(vim.api.nvim_get_current_win()))
        else
            vim.api.nvim_set_current_win(where)
        end
    else  -- buffer
        local last = vim.api.nvim_get_current_buf()
        if where == 0 then  -- alt
            local alt = tabs.get_alt_buf(vim.api.nvim_get_current_win())
            if alt then
                vim.api.nvim_set_current_buf(alt)
            end
        else  -- to is an index (shown on the bar)
            local bufs = tabs.get_var('tabs_buflist', 'w')
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

function tabs_close()
    -- close current tab
    if vim.api.nvim_buf_get_option(0, 'modified') then
        print("File modified")
        return
    end
    local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
    local alt = tabs.get_alt_buf(0)
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
    tabs_reload()
end

vim.api.nvim_create_augroup("tabs", { clear = true })
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile', 'BufLeave', 'FileType', 'TermOpen'}, {
    group = "tabs",
    callback = tabs_reload,
})
vim.api.nvim_create_autocmd('WinLeave', {
    group = "tabs",
    callback = function() vim.api.nvim_set_var('tabs_alt_win', vim.api.nvim_get_current_win()) end,
})
