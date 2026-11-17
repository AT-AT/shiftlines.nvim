-- =================================================================================================
--  Loaded Module
-- =================================================================================================

---@see vim.api
---
local api = vim.api

---@see vim.fn
---
local fn = vim.fn

---@module 'shiftlines.const'
---
local const = require('shiftlines.const')


-- =================================================================================================
--  Namespace
-- =================================================================================================

local M = {}


-- =================================================================================================
--  Definition
-- =================================================================================================

M.ESC_KEY_SEQ = api.nvim_replace_termcodes('<Esc>', true, false, true)


-- =================================================================================================
--  Function (API)
-- =================================================================================================

--- Shift downward.
---
function M.shift_downward()
  M.shift(const.SHIFT_DIRECTION.DOWNWARD)
end

--- Shift upward.
---
function M.shift_upward()
  M.shift(const.SHIFT_DIRECTION.UPWARD)
end


-- =================================================================================================
--  Function (Helper)
-- =================================================================================================

--- Determine whether the mode is acceptable.
---
---@private
---@return boolean
---
function M.can_accept_mode()
  local mode = api.nvim_get_mode().mode

  return mode == 'n' or mode == 'V'
end

--- Determine whether the derived insertion row is valid.
---
---@private
---@param row integer
---@return boolean
---
function M.can_shift_to(row)
  local line_count = api.nvim_buf_line_count(const.NVIM_API.CURRENT_BUF_ID)

  return row >= 0 and row <= line_count
end

--- Derive the insertion row.
---
---@private
---@param row_range row_range
---@param direction shift_direction
---@return integer
---
--- Note:
---   - The "move" command inserts the target row(s) BELOW the specified row number.
---   - Upward:
---       ":2,3move 0" (move 2~3 to 0, dest_row(0) = from-row(2) - 1(backward) - 1(below)
---         - 0(*)
---         - 1     A      |B|
---         - 2    |B| --> |C|
---         - 3    |C|      A
---   - Downward:
---       ":1,2move 3" (move 1~2 to 3, dest_row(3) = from-row(1) + row-count(2)
---         - 1    |A|     (*)      C
---         - 2    |B| --> (*) --> |A|
---         - 3     C       C      |B|
---                         A
---                         B
---     (*) ... virtually gap/row
---
function M.insertion_row_for(row_range, direction)
  if direction == const.SHIFT_DIRECTION.DOWNWARD then
    return row_range.from + row_range.count
  elseif direction == const.SHIFT_DIRECTION.UPWARD then
    return row_range.from - 2
  else
    return -1
  end
end

--- Restore the selection and cursor position to the destination.
---
---@private
---@param state state
---
function M.restore_state(state)
  local win_id = const.NVIM_API.CURRENT_WIN_ID

  if not state.selection.selected then
    api.nvim_win_set_cursor(win_id, { state.cursor.row, state.cursor.col })

    return
  end

  -- If the cursor moves to a line other than the last line of a selection, the selection itself is
  -- automatically adjusted. Therefore, the cursor must always be positioned at the end of the
  -- selection; as a result, if lines are selected from bottom to top, the selection range must be
  -- restored accordingly.
  local reverse = (state.selection.count > 1) and (state.selection.from == state.cursor.row)
  local from, to = state.selection.from, state.selection.to

  if reverse then
    from, to = state.selection.to, state.selection.from
  end

  -- If a restore operation is performed while the original range selection remains active, the
  -- correct result will not be obtained.
  api.nvim_feedkeys(M.ESC_KEY_SEQ, 'nx', false)

  api.nvim_win_set_cursor(win_id, { from, 0 })

  -- By executing "Normal !(bang)", restrict the operation to Vim's native functionality only.
  vim.cmd.normal({
    args = { 'V' },
    bang = true,
  })

  api.nvim_win_set_cursor(win_id, { to, state.cursor.col })
end

--- Shift the target.
---
---@private
---@param direction shift_direction
---
function M.shift(direction)
  if not M.can_accept_mode() then
    return
  end

  local origin_state = M.state()
  local row_range = origin_state.selection
  local insertion_row = M.insertion_row_for(row_range, direction)

  if not M.can_shift_to(insertion_row) then
    return
  end

  -- Since marks are also moved, the "move" command is used.
  vim.cmd({
    cmd = 'move',
    range = { row_range.from, row_range.to },
    args = { insertion_row },
  })

  local shifted_state = M.shift_state(origin_state, direction)

  M.restore_state(shifted_state)
end

--- Shift the state of the target.
---
---@private
---@param state state
---@param direction shift_direction
---@return state
---
function M.shift_state(state, direction)
  local row_delta = 0

  if direction == const.SHIFT_DIRECTION.DOWNWARD then
    row_delta = 1
  elseif direction == const.SHIFT_DIRECTION.UPWARD then
    row_delta = -1
  end

  local selection = {
    from = state.selection.from + row_delta,
    to = state.selection.to + row_delta,
  }

  local cursor = {
    row = state.cursor.row + row_delta,
  }

  local shifted = {
    selection = selection,
    cursor = cursor,
  }

  return vim.tbl_deep_extend('force', state, shifted)
end

--- Retrieve the state of the target being shifted.
---
---@private
---@return state
---
function M.state()
  local cursor_pos = api.nvim_win_get_cursor(const.NVIM_API.CURRENT_WIN_ID)

  cursor_pos = {
    row = cursor_pos[1],
    col = cursor_pos[2],
  }

  local row_from = fn.getpos('v')[2]
  local row_to = cursor_pos.row

  local selection = {
    from = math.min(row_from, row_to),
    to = math.max(row_from, row_to),
    selected = api.nvim_get_mode().mode == 'V',
  }

  selection.count = selection.to - selection.from + 1

  return {
    cursor = cursor_pos,
    selection = selection,
  }
end


-- =================================================================================================
--  Export
-- =================================================================================================

return M
