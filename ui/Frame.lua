local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Base = require(ui_path .. 'Base')
local Closeable = require(ui_path .. 'Closeable')
local Draggable = require(ui_path .. 'Draggable')
local Resizable = require(ui_path .. 'Resizable')
local Frame = Object:extend('Frame')
Frame:implement(Base)
Frame:implement(Closeable)
Frame:implement(Draggable)
Frame:implement(Resizable)

function Frame:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Frame'

    self:baseNew(x, y, w, h, settings)

    self:bind('tab', 'focus-next')
    self:bind('lshift', 'previous-modifier')

    self.closeable = settings.closeable or false
    if self.closeable then
        settings.annotation = "Frame's close button"
        self:closeableNew(settings)
    end
    self.draggable = settings.draggable or false
    if self.draggable then self:draggableNew(settings) end
    self.resizable = settings.resizable or false
    if self.resizable then self:resizableNew(settings) end

    self.elements = {}
    self.currently_focused_element = nil
end

function Frame:update(dt, parent)
    if self.closed then return end
    self:basePreUpdate(dt, parent)
    local x, y = love.mouse.getPosition()

    if self.resizable then self:resizableUpdate(dt) end
    if self.closeable then self:closeableUpdate(dt) end
    if self.draggable then self:draggableUpdate(dt) end

    -- Focus on elements
    if self.selected and not self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusNext() end
    if self.selected and self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusPrevious() end
    for i, element in ipairs(self.elements) do
        if not element.selected or not i == self.currently_focused_element then
            element.selected = false
        end
        if i == self.currently_focused_element then
            element.selected = true
        end
    end
    -- Unfocus all elements if the frame isn't being interacted with
    if not self.selected then
        for i, element in ipairs(self.elements) do
            element.selected = false
        end
    end

    for _, element in ipairs(self.elements) do element:update(dt, self) end

    self:basePostUpdate(dt)
end

function Frame:draw()
    if self.closed then return end
    self:baseDraw()
    if self.closeable then self:closeableDraw() end
    for _, element in ipairs(self.elements) do element:draw() end
end

function Frame:addElement(element)
    element.parent = self
    table.insert(self.elements, element)
    return element
end

function Frame:focusNext()
    for i, element in ipairs(self.elements) do 
        if element.selected then self.currently_focused_element = i end
        element.selected = false 
    end
    if self.currently_focused_element then
        self.currently_focused_element = self.currently_focused_element + 1
        if self.currently_focused_element > #self.elements then
            self.currently_focused_element = 1
        end
    else self.currently_focused_element = 1 end
end

function Frame:focusPrevious()
    for i, element in ipairs(self.elements) do 
        if element.selected then self.currently_focused_element = i end
        element.selected = false 
    end
    if self.currently_focused_element then
        self.currently_focused_element = self.currently_focused_element - 1
        if self.currently_focused_element < 1 then
            self.currently_focused_element = #self.elements
        end
    else self.currently_focused_element = #self.elements end
end

return Frame

