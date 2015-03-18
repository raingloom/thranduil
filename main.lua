UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    UI.registerEvents()

    button = UI.Button(10, 10, 50, 50, {extensions = {TestTheme.Button}, draggable = true, resizable = true})
    checkbox = UI.Checkbox(70, 10, 50, 50, {extensions = {TestTheme.Checkbox}, draggable = true, resizable = true})
    slider = UI.Slider(10, 70, 110, 40, {extensions = {TestTheme.Slider}, value_interval = 10, draggable = true, resizable = true})

    frame = UI.Frame(130, 10, 100, 100, {extensions = {TestTheme.Frame}, draggable = true, closeable = true, close_button_extensions = {TestTheme.Button}, resizable = true})
    frame:addElement(UI.Button(10, 35, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Checkbox(40, 35, 25, 25, {extensions = {TestTheme.Checkbox}}))
    frame:addElement(UI.Slider(10, 65, 55, 25, {extensions = {TestTheme.Slider}, value_interval = 5}))

    scrollarea = UI.Scrollarea(240, 10, 395, 395, {extensions = {TestTheme.Scrollarea}, scrollbar_button_extensions = {TestTheme.Button}, area_width = 185, area_height = 185, show_scrollbars = true})
    for i = 5, 365, 30 do for j = 5, 365, 30 do scrollarea:addElement(UI.Checkbox(j, i, 25, 25, {extensions = {TestTheme.Checkbox}})) end end

    frame_4 = UI.Frame(10, 120, 220, 400, {extensions = {TestTheme.Frame}})
    local frame_2 = UI.Frame(10, 10, 55, 70, {extensions = {TestTheme.Frame}, draggable = true, resizable = true})
    frame_2:addElement(UI.Checkbox(5, 20, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_2:addElement(UI.Checkbox(5, 45, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_2:addElement(UI.Checkbox(30, 20, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_2:addElement(UI.Checkbox(30, 45, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_4:addElement(frame_2)
    local frame_3 = UI.Frame(155, 10, 55, 70, {extensions = {TestTheme.Frame}, draggable = true, resizable = true})
    frame_3:addElement(UI.Checkbox(5, 20, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_3:addElement(UI.Checkbox(5, 45, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_3:addElement(UI.Checkbox(30, 20, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_3:addElement(UI.Checkbox(30, 45, 20, 20, {extensions = {TestTheme.Checkbox}}))
    frame_4:addElement(frame_3)
    local scrollarea_2 = UI.Scrollarea(10, 90, 400, 600, {extensions = {TestTheme.Scrollarea}, scrollbar_button_extensions = {TestTheme.Button}, area_width = 180, area_height = 280, show_scrollbars = true})
    scrollarea_2:addElement(UI.Frame(10, 10, 55, 70, {extensions = {TestTheme.Frame}, draggable = true, resizable = true}))
    frame_4:addElement(scrollarea_2)

    scrollarea_3 = UI.Scrollarea(450, 10, 400, 400, {extensions = {TestTheme.Scrollarea}, scrollbar_button_extensions = {TestTheme.Button}, area_width = 325, area_height = 185, show_scrollbars = true})
    scrollarea_3:addElement(UI.Textarea(10, 10, 380, 380, {extensions = {TestTheme.Textarea}}))

    frame_5 = UI.Frame(240, 220, 200, 370, {extensions = {TestTheme.Frame}, draggable = true, drag_margin = 10, resizable = true, resize_margin = 5})
    frame_5:addElement(UI.Textarea(10, 20, 180, 340, {extensions = {TestTheme.Textarea}, text_margin = 3}))
end

function love.update(dt)
    button:update(dt)
    checkbox:update(dt)
    slider:update(dt)
    frame:update(dt)
    scrollarea:update(dt)
    frame_4:update(dt)
    --scrollarea_3:update(dt)
    frame_5:update(dt)
end

function love.draw()
    button:draw()
    checkbox:draw()
    slider:draw()
    frame:draw()
    scrollarea:draw()
    frame_4:draw()
    --scrollarea_3:draw()
    frame_5:draw()
end
