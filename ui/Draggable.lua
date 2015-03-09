local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Draggable = Object:extend('Draggable')

function Draggable:draggableNew(settings)
    local settings = settings or {}
    self.dragging = false
    self.drag_hot = false
    self.drag_enter = false
    self.drag_exit = false
    self.drag_margin = settings.drag_margin or self.h/5
    self.previous_drag_hot = false
    self.previous_mouse_position = nil
end

function Draggable:draggableUpdate(dt)
    local x, y = love.mouse.getPosition()

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

    -- Set previous frame state
    self.previous_drag_hot = self.drag_hot
    self.previous_mouse_position = {x = x, y = y}
end

return Draggable
