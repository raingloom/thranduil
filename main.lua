UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    UI.registerEvents()

    math.randomseed(os.time())

    textarea = UI.Textarea(100, 100, 200, 200, {extensions = {TestTheme.Textarea}})
    textarea:setTextSettings({red = function(dt, c) love.graphics.setColor(255, 0, 0) end})
    textarea.wrap_text_in = {'red'}
end

function love.update(dt)
    textarea:update(dt)
end

function love.draw()
    textarea:draw()
end

function love.keypressed(key)
    --[[
    if key == ' ' then
        frame:addElement(UI.Button(0, 0, math.random(15, 50), math.random(15, 25), {extensions = {TestTheme.Button}}))
    end
    ]]--
end

-- DIFF
--
-- getMousePosition
-- overlay
-- close_margin_top, close_margin_right
-- auto_align, auto_spacing, auto_margin
-- container select directions
-- container focuselement forceunselect destroy
-- drag start, drag end
-- resize margin top, right, left, bottom
-- resize corner, corner width, height
-- resize start, resize end
-- vertical slider
-- slide start, end
-- slide drag improved
-- slide moveup movedown
-- textarea tab, tab width
-- textarea undo/redo
-- textarea enter
-- textarea tags
-- improved cursor selection
-- cursor visible, cursor blink
