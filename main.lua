UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    UI.registerEvents()

    button = UI.Button(10, 10, 50, 50, {extensions = {TestTheme.Button}, draggable = true, resizable = true})
    checkbox = UI.Checkbox(70, 10, 50, 50, {extensions = {TestTheme.Checkbox}, draggable = true, resizable = true})
    frame = UI.Frame(130, 10, 100, 100, {extensions = {TestTheme.Frame}, draggable = true, closeable = true, close_button_extensions = {TestTheme.Button}, resizable = true})
    slider = UI.Slider(10, 70, 110, 40, {extensions = {TestTheme.Slider}, value_interval = 10, draggable = true, resizable = true})
    scrollarea = UI.Scrollarea(240, 10, 395, 395, {extensions = {TestTheme.Scrollarea}, scrollbar_button_extensions = {TestTheme.Button}, area_width = 185, area_height = 185, show_scrollbars = true})

    frame:addElement(UI.Button(10, 35, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Checkbox(40, 35, 25, 25, {extensions = {TestTheme.Checkbox}}))
    frame:addElement(UI.Slider(10, 65, 55, 25, {extensions = {TestTheme.Slider}, value_interval = 5}))

    for i = 5, 365, 30 do
        for j = 5, 365, 30 do
            scrollarea:addElement(UI.Checkbox(j, i, 25, 25, {extensions = {TestTheme.Checkbox}}))
        end
    end
end

function love.update(dt)
    button:update(dt)
    checkbox:update(dt)
    slider:update(dt)
    frame:update(dt)
    scrollarea:update(dt)
end

function love.draw()
    button:draw()
    checkbox:draw()
    slider:draw()
    frame:draw()
    scrollarea:draw()
end
