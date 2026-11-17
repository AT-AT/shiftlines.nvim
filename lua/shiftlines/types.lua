-- =================================================================================================
--  Types
-- =================================================================================================

-- https://github.com/LuaLS/lua-language-server/discussions/1436#discussioncomment-3318346
---@class PluginOptions
---@field event_name string

---@alias cursor_pos { row: integer, col: integer } 1,0-indexed
---@alias row_range { from: integer, to: integer, count: integer, selected: boolean } 1~n-indexed
---@alias state { selection: row_range, cursor: cursor_pos }
