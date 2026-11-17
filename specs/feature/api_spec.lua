package.loaded['specs/helpers'] = nil

local H = require('specs/helpers')
local eq = MiniTest.expect.equality
local child = H.new_child_neovim('shiftlines')

-- / API
-- -------------------------------------------------------------------------------------------------
describe('API', function()

  before_each(function()
    child.setup()
  end)

  teardown(function()
    child.stop()
  end)

  -- / Subject
  -- -----------------------------------------------------------------------------------------------
  describe('shift_downward()', function()

    it('can shift line(s) to next using internal module with user event', function()
      -- Arrange
      local buf_id = child.prepare_words('foo', 'bar', 'baz')
      child.type_keys('V')
      local event_name = child.config_of('event_name')
      child.create_event_watcher(event_name)

      -- Act
      child.lua([[SUT.shift_downward()]])
      local actual_text = child.grub_text(1, 3)
      local actual_ev_result = child.grub_event_result()

      -- Assert
      eq({'bar', 'foo', 'baz'}, actual_text)
      eq(1, actual_ev_result.count)
      eq(1, vim.tbl_count(actual_ev_result.data))
      eq(buf_id, actual_ev_result.data[1].buf_id)
    end)

  end)

  -- / Subject
  -- -----------------------------------------------------------------------------------------------
  describe('shift_upward()', function()

    it('can shift line(s) to previous using internal module with user event', function()
      -- Arrange
      local buf_id = child.prepare_words('foo', 'bar', 'baz')
      child.type_keys('jjV')
      local event_name = child.config_of('event_name')
      child.create_event_watcher(event_name)

      -- Act
      child.lua([[SUT.shift_upward()]])
      local actual_text = child.grub_text(1, 3)
      local actual_ev_result = child.grub_event_result()

      -- Assert
      eq({'foo', 'baz', 'bar'}, actual_text)
      eq(1, actual_ev_result.count)
      eq(1, vim.tbl_count(actual_ev_result.data))
      eq(buf_id, actual_ev_result.data[1].buf_id)
    end)

  end)

end)
