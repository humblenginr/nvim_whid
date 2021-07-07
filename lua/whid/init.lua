local api = vim.api
local buf, win

local function open_window()
  buf = api.nvim_create_buf(false,true)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height*0.8 - 4)
  local win_width = math.ceil(width*0.8)

  local row = math.ceil(height - win_height)
  local col = math.ceil((width - win_width)/2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col
  }

  win = api.nvim_open_win(buf, true, opts)

end

local position = 0

local function update_view(direction)
  api.nvim_buf_set_option(buf, 'modifiable', true)

  position = position + direction

  if position<0 then
   position = 0
  end

  local result = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r  HEAD~'..position)

  for k,v in pairs(result) do
    result[k] = '  '..result[k]
  end

  local function center(str)
    local width = api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
    return str.rep(" ", shift) .. str
  end


  api.nvim_buf_set_lines(buf,0, -1, false, {
    center("What have i done?"),
    center('HEAD~'..position),
    ''
  })

  api.nvim_buf_set_lines(buf,0,-1,false,result)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end


local function set_mappings()
  local mappings = {
    ['['] = 'update_view(-1)',
    [']'] = 'update_view(1)',
    ['<cr>'] = 'open_file()',
    h = 'update_view(-1)',
    l = 'update_view(1)',
    q = 'close_window()',
    k = 'move_cursor()'
  }

  for k,v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"whid".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end


local function close_window()
  api.nvim_win_close(win, true)
end

local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, {new_pos, 0})
end

local function open_file()
  local str = api.nvim_get_current_line()
  close_window()
  api.nvim_command('edit '..str)
end


local function whid()
  position = 0 -- if you want to preserve last displayed state just omit this line
  open_window()
  set_mappings()
  update_view(0)
  api.nvim_win_set_cursor(win, {4, 0}) -- set cursor on first list entry
end

return {
  whid = whid,
  update_view = update_view,
  open_file = open_file,
  move_cursor = move_cursor,
  close_window = close_window
}
