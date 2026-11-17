package.loaded['specs/helpers'] = nil

local H = require('specs/helpers')
-- local eq, ne = MiniTest.expect.equality, MiniTest.expect.no_equality
-- local error, no_error = MiniTest.expect.error, MiniTest.expect.no_error
-- local has_mark = H.expect.has_mark
-- local is_null, is_not_null = H.expect.is_null, H.expect.is_not_null
local child = H.new_child_neovim('shiftlines.XXXXX')

-- / Module
-- -------------------------------------------------------------------------------------------------
describe('Module.XXXXX', function()

  before_each(function()
    child.setup()
  end)

  teardown(function()
    child.stop()
  end)

  -- / Category
  -- -----------------------------------------------------------------------------------------------
  describe('XXXXX', function()

    -- / Subject
    -- ---------------------------------------------------------------------------------------------
    describe('XXXXX()', function()

      it('-----XXXXX-----', function()
        -- Arrange

        -- Act

        -- Assert
      end)

    end)

  end)

end)
