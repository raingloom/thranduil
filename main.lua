UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    UI.registerEvents()

    button = UI.Button(10, 10, 50, 50, {extensions = {TestTheme.Button}})
    checkbox = UI.Checkbox(70, 10, 50, 50, {extensions = {TestTheme.Checkbox}})
    frame = UI.Frame(130, 10, 100, 100, {extensions = {TestTheme.Frame}, draggable = true, closeable = true, close_button_extensions = {TestTheme.Button}, resizable = true})
    slider = UI.Slider(10, 70, 110, 40, {extensions = {TestTheme.Slider}, value_interval = 10})

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
