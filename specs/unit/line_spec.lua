package.loaded['specs/helpers'] = nil

local H = require('specs/helpers')
local eq = MiniTest.expect.equality
local has_mark = H.expect.has_mark
local child = H.new_child_neovim('shiftlines.line')

-- / Module
-- -------------------------------------------------------------------------------------------------
describe('Module.line', function()

  before_each(function()
    child.setup()
  end)

  teardown(function()
    child.stop()
  end)

  -- / Subject
  -- -----------------------------------------------------------------------------------------------
  describe('shift_downward()', function()

    describe('mode detection', function()

      it('does nothing except in modes normal and V-Line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('mavll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 1 }, actual_marks)
        eq({ 1, 1 }, actual_selection)
        eq({ 1, 2 }, actual_cursor)
      end)

    end)

    describe('single line (not selected)', function()

      it('can shift line to next with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('mall')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'bar', 'foo', 'baz'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq(false, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift line beyond last line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('jjmall')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 3 }, actual_marks)
        eq(false, actual_selection)
        eq({ 3, 2 }, actual_cursor)
      end)

    end)

    describe('single line (selected)', function()

      it('can shift line to next with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('maVll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'bar', 'foo', 'baz'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 2 }, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift line beyond last line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('jjmaVll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 3 }, actual_marks)
        eq({ 3, 3 }, actual_selection)
        eq({ 3, 2 }, actual_cursor)
      end)

    end)

    describe('multiple lines', function()

      it('can shift lines to next with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('maVjjll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'qux', 'foo', 'bar', 'baz', 'quux'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 4 }, actual_selection)
        eq({ 4, 2 }, actual_cursor)
      end)

      it('can shift lines selected in opposite direction to next with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('majjVkkll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'qux', 'foo', 'bar', 'baz', 'quux'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 4 }, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift lines beyond last line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('jjmaVjjll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz', 'qux', 'quux'}, actual_text)
        has_mark({ 'a', 3 }, actual_marks)
        eq({ 3, 5 }, actual_selection)
        eq({ 5, 2 }, actual_cursor)
      end)

    end)

  end)

  -- / Subject
  -- -----------------------------------------------------------------------------------------------
  describe('shift_upward()', function()

    describe('mode detection', function()

      it('does nothing except in modes normal and V-Line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('jjmavll')

        -- Act
        child.lua([[SUT.shift_downward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 3 }, actual_marks)
        eq({ 3, 3 }, actual_selection)
        eq({ 3, 2 }, actual_cursor)
      end)

    end)

    describe('single line (not selected)', function()

      it('can shift line to previous with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('jjmall')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'baz', 'bar'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq(false, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift line beyond first line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('mall')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 1 }, actual_marks)
        eq(false, actual_selection)
        eq({ 1, 2 }, actual_cursor)
      end)

    end)

    describe('single line (selected)', function()

      it('can shift line to previous with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('jjmaVll')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'baz', 'bar'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 2 }, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift line beyond first line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz')
        child.type_keys('maVll')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 3)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz'}, actual_text)
        has_mark({ 'a', 1 }, actual_marks)
        eq({ 1, 1 }, actual_selection)
        eq({ 1, 2 }, actual_cursor)
      end)

    end)

    describe('multiple lines', function()

      it('can shift lines to previous with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('jjmaVjjll')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'baz', 'qux', 'quux', 'bar'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 4 }, actual_selection)
        eq({ 4, 2 }, actual_cursor)
      end)

      it('can shift lines selected in opposite direction to previous with mark', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('jjmajjVkkll')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'baz', 'qux', 'quux', 'bar'}, actual_text)
        has_mark({ 'a', 2 }, actual_marks)
        eq({ 2, 4 }, actual_selection)
        eq({ 2, 2 }, actual_cursor)
      end)

      it('cannot shift lines beyond first line', function()
        -- Arrange
        child.prepare_words('foo', 'bar', 'baz', 'qux', 'quux')
        child.type_keys('maVjjll')

        -- Act
        child.lua([[SUT.shift_upward()]])
        local actual_text = child.grub_text(1, 5)
        local actual_marks = child.grub_marks()
        local actual_selection = child.grub_selection_row()
        local actual_cursor = child.grub_cursor_pos()

        -- Assert
        eq({'foo', 'bar', 'baz', 'qux', 'quux'}, actual_text)
        has_mark({ 'a', 1 }, actual_marks)
        eq({ 1, 3 }, actual_selection)
        eq({ 3, 2 }, actual_cursor)
      end)

    end)

  end)

end)
