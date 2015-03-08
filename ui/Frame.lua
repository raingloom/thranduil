local Object = require((...):sub(1, (...):find('/')) .. 'classic/classic')
local Frame = Object:extend('Frame')

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
    self.closing = false
    self.closed = settings.closed or false
    self.close_margin = settings.close_margin or 5
    self.close_button_width = settings.close_button_width or 10
    self.close_button_height = settings.close_button_height or 10
    self.close_button = self.ui.Button(self.w - self.close_margin - self.close_button_width, self.close_margin,
                                       self.close_button_width, self.close_button_height, 
                                      {extensions = settings.close_button_extensions or {}, annotation = "Frame's close button"})

    self.draggable = settings.draggable or false
    self.drag_hot = false
    self.drag_enter = false
    self.drag_exit = false
    self.dragging = false
    self.drag_margin = settings.drag_margin or self.h/5

    self.resizable = settings.resizable or false
    self.resize_hot = false
    self.resizing = false
    self.resize_margin = settings.resize_margin or 6
    self.min_width = settings.min_width or 20
    self.min_height = settings.min_height or self.h/5
    self.resize_drag_x = nil
    self.resize_drag_y = nil

    self.elements = {}
    self.currently_focused_element = nil

    self.previous_mouse_position = nil
    self.previous_hot = false
    self.previous_selected = false
    self.previous_drag_hot = false

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

    if self.draggable then
        -- Check for drag_hot
        if self.hot and x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.drag_margin then
            self.drag_hot = true
        else self.drag_hot = false end

        -- Check for drag_enter
        if self.drag_hot and not self.previous_drag_hot then
            self.drag_enter = true
        else self.drag_enter = false end

        -- Check for drag_exit
        if not self.drag_hot and self.previous_drag_hot then
            self.drag_exit = true
        else self.drag_exit = false end
    end

    if self.resizable then
        -- Check for resize_hot
        if (x >= self.x and x <= self.x + self.resize_margin and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_margin) or
           (x >= self.x + self.w - self.resize_margin and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_margin and y <= self.y + self.h) then
            self.resize_hot = true 
        else self.resize_hot = false end
    end

    -- Close
    if self.close_button.pressed then
        self.closing = true
    end
    if self.closing and self.close_button.released then
        self.closed = true
        self.closing = false
    end
    if self.selected and self.input:pressed('close') then
        self.closed = true
    end

    -- Drag
    if self.drag_hot and self.input:pressed('left-click') then
        self.dragging = true
    end
    -- Resizing has precedence over dragging
    if self.dragging and not self.resizing and self.input:down('left-click') then
        local dx, dy = x - self.previous_mouse_position.x, y - self.previous_mouse_position.y
        self.x, self.y = self.x + dx, self.y + dy
    end
    if self.dragging and self.input:released('left-click') then
        self.dragging = false
    end

    -- Resize
    if self.resize_hot and self.input:pressed('left-click') then
        self.resizing = true
        if (x >= self.x and x <= self.x + self.resize_margin and y >= self.y and y <= self.y + self.h) then self.resize_drag_x = -1 end
        if (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_margin) then self.resize_drag_y = -1 end
        if (x >= self.x + self.w - self.resize_margin and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) then self.resize_drag_x = 1 end
        if (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_margin and y <= self.y + self.h) then self.resize_drag_y = 1 end
    end
    if self.resizing and self.input:down('left-click') then
        local dx, dy = x - self.previous_mouse_position.x, y - self.previous_mouse_position.y
        if self.resize_drag_x == -1 then self.x = self.x + dx end
        if self.resize_drag_y == -1 then self.y = self.y + dy end
        if self.resize_drag_x then self.w = math.max(self.w + self.resize_drag_x*dx, self.min_width) end
        if self.resize_drag_y then self.h = math.max(self.h + self.resize_drag_y*dy, self.min_height) end
    end
    if self.resizing and self.input:released('left-click') then
        self.resizing = false
        self.resize_drag_x = nil
        self.resize_drag_y = nil
    end

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

    if self.closeable then 
        self.close_button:update(dt, self) 
    end

    -- Update extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.update then extension.update(self, dt, parent) end
    end

    for _, element in ipairs(self.elements) do element:update(dt, self) end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_selected = self.selected
    self.previous_drag_hot = self.drag_hot
    self.previous_mouse_position = {x = x, y = y}

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

