UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    button = UI.Button(10, 10, 50, 50, {extensions = {TestTheme.Button}})
    checkbox = UI.Checkbox(100, 10, 50, 50, {extensions = {TestTheme.Checkbox}})
    frame = UI.Frame(200, 10, 100, 100, {extensions = {TestTheme.Frame}, draggable = true, closeable = true, close_button_extensions = {TestTheme.Button}, resizable = true})
    slider = UI.Slider(10, 100, 100, 30, {extensions = {TestTheme.Slider}, value_interval = 10})

    frame:addElement(UI.Button(10, 25, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Checkbox(40, 25, 25, 25, {extensions = {TestTheme.Checkbox}}))
    frame:addElement(UI.Slider(10, 55, 55, 25, {extensions = {TestTheme.Slider}, value_interval = 5}))
end

function love.update(dt)
    button:update(dt)
    checkbox:update(dt)
    slider:update(dt)
    frame:update(dt)

end

function love.draw()
    button:draw()
    checkbox:draw()
    slider:draw()
    frame:draw()
end

function love.keypressed(key)
    UI.keypressed(key)
end

function love.keyreleased(key)
    UI.keyreleased(key)
end

function love.mousepressed(x, y, button)
    UI.mousepressed(button)
end

function love.mousereleased(x, y, button)
    UI.mousereleased(button)
end

function love.gamepadpressed(joystick, button)
    UI.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    UI.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, value)
    UI.gamepadaxis(joystick, axis, value)
end

function love.textinput(text)
    UI.textinput(text)
end
