-- $ echo hola

local function doit()
    -- vim.cmd[[silent update!]]
    -- vim.cmd[[wincmd k]]
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
    if first_line == '' then
        return
    end
    local i_start_cmd = string.find(first_line, ' $', 1, true)
    if i_start_cmd == nil then
        return
    end
    i_start_cmd = i_start_cmd + 2 -- without the prompt
    if string.sub(first_line, i_start_cmd, i_start_cmd) == ' ' then
        i_start_cmd = i_start_cmd + 1 -- without the preceding space
    end
    local cmd = string.sub(first_line, i_start_cmd)
    local dir = vim.fn.expand('%:h')
    term(cmd, dir)
    vim.cmd[[norm i]]
end

return {doit = doit}
