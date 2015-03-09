local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Closeable = require(ui_path .. 'Closeable')
local Draggable = require(ui_path .. 'Draggable')
local Resizable = require(ui_path .. 'Resizable')
local Frame = Object:extend('Frame')
Frame:implement(Closeable)
Frame:implement(Draggable)
Frame:implement(Resizable)

function Frame:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Frame'

    self.ix, self.iy = x, y
    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('tab', 'focus-next')
    self.input:bind('lshift', 'previous-modifier')
    self.input:bind('mouse1', 'left-click')
    self.input:bind('escape', 'close')

    self.hot = false
    self.selected = false
    self.down = false
    self.enter = false
    self.exit = false
    self.selected_enter = false
    self.selected_exit = false

    self.closeable = settings.closeable or false
    if self.closeable then
        settings.annotation = "Frame's close button"
        self:closeableNew(settings)
    end

    self.draggable = settings.draggable or false
    if self.draggable then 
        self:draggableNew(settings) 
    end

    self.resizable = settings.resizable or false
    if self.resizable then 
        self:resizableNew(settings) 
    end

    self.elements = {}
    self.currently_focused_element = nil

    self.previous_hot = false
    self.previous_selected = false

    -- Initialize extesions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.new then extension.new(self) end
    end
end

function Frame:update(dt, parent)
    if self.closed then return end

    local x, y = love.mouse.getPosition()
    if parent then self.x, self.y = parent.x + self.ix, parent.y + self.iy end

    -- Check for hot
    if x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h then
        self.hot = true
    else self.hot = false end

    -- Check for enter 
    if self.hot and not self.previous_hot then
        self.enter = true
    else self.enter = false end

    -- Check for exit
    if not self.hot and self.previous_hot then
        self.exit = true
    else self.exit = false end

    -- Set focused or not
    if self.hot and self.input:pressed('left-click') then
        self.selected = true
    elseif not self.hot and self.input:pressed('left-click') then
        self.selected = false
    end

    -- Check for selected_enter
    if self.selected and not self.previous_selected then
        self.selected_enter = true
    else self.selected_enter = false end

    -- Check for selected_exit
    if not self.selected and self.previous_selected then
        self.selected_exit = true
    else self.selected_exit = false end

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

    -- Update extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.update then extension.update(self, dt, parent) end
    end

    for _, element in ipairs(self.elements) do element:update(dt, self) end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_selected = self.selected

    self.input:update(dt)
end

function Frame:draw()
    if self.closed then return end

    -- Draw extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.draw then extension.draw(self) end
    end

    if self.closeable then self.close_button:draw() end
    for _, element in ipairs(self.elements) do element:draw() end
end

function Frame:addElement(element)
    element.parent = self
    table.insert(self.elements, element)
    return element
end

function Frame:bind(key, action)
    self.input:bind(key, action)
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

