local M = {}

local function get_var(name, scope, id)
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
    local bufs = get_var('tabs_buflist', 'w', win) or {}
    local l_bufs = vim.tbl_count(bufs)
    if l_bufs < 2 then
        return
    end
    local alt = get_var('tabs_alt_file', 'w', win)
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
    local alt_win = get_var('tabs_alt_win')
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

M.get_alt_buf = get_alt_buf
M.get_alt_win = get_alt_win
M.get_var = get_var

return M
