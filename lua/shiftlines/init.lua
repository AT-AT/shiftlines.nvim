-- =================================================================================================
--  Loaded Module
-- =================================================================================================

---@see vim.api
---
local api = vim.api

---@module 'shiftlines.config'
---
local config = require('shiftlines.config')

---@module 'shiftlines.line'
---
local line = require('shiftlines.line')


-- =================================================================================================
--  Namespace
-- =================================================================================================

local M = {}


-- =================================================================================================
--  Function (API)
-- =================================================================================================

---@param local_options PluginOptions?
---
function M.setup(local_options)
  config.merge_options(local_options or {})
end

-- -------------------------------------------------------------------------------------------------

--- Shift downward.
---
function M.shift_downward()
  line.shift_downward()
  M.emit_event()
end

--- Shift upward.
---
function M.shift_upward()
  line.shift_upward()
  M.emit_event()
end


-- =================================================================================================
--  Function (Helper)
-- =================================================================================================

--- Trigger an event when the row shift is complete.
---
---@private
---
function M.emit_event()
  vim.api.nvim_exec_autocmds('User', {
    pattern = config.options.event_name,
    data = {
      buf_id = api.nvim_get_current_buf(),
    },
  })
end


-- =================================================================================================
--  Export
-- =================================================================================================

return {
  setup = M.setup,
  shift_downward = M.shift_downward,
  shift_upward = M.shift_upward,
}
