local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Resizable = Object:extend('Resizable')

function Resizable:resizableNew(settings)
    local settings = settings or {}
    self.resizing = false
    self.resize_hot = false
    self.resize_margin = settings.resize_margin or 6
    self.min_width = settings.min_width or 20
    self.min_height = settings.min_height or self.h/5
    self.resize_drag_x, self.resize_drag_y = nil, nil
    self.resize_x, self.resize_y = 0, 0
    self.resize_previous_mouse_position = nil
end

function Resizable:resizableUpdate(dt)
    local x, y = love.mouse.getPosition()

    if self.resizable then
        -- Check for resize_hot
        if (x >= self.x and x <= self.x + self.resize_margin and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_margin) or
           (x >= self.x + self.w - self.resize_margin and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) or
           (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_margin and y <= self.y + self.h) then
            self.resize_hot = true 
        else self.resize_hot = false end
    end

    if self.resize_hot and self.input:pressed('left-click') then
        self.resizing = true
        if (x >= self.x and x <= self.x + self.resize_margin and y >= self.y and y <= self.y + self.h) then self.resize_drag_x = -1 end
        if (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.resize_margin) then self.resize_drag_y = -1 end
        if (x >= self.x + self.w - self.resize_margin and x <= self.x + self.w and y >= self.y and y <= self.y + self.h) then self.resize_drag_x = 1 end
        if (x >= self.x and x <= self.x + self.w and y >= self.y + self.h - self.resize_margin and y <= self.y + self.h) then self.resize_drag_y = 1 end
    end

    if self.resizing and self.input:down('left-click') then
        local dx, dy = x - self.resize_previous_mouse_position.x, y - self.resize_previous_mouse_position.y
        if self.resize_drag_x == -1 then self.resize_x = self.resize_x + dx end
        if self.resize_drag_y == -1 then self.resize_y = self.resize_y + dy end
        if self.resize_drag_x then self.w = math.max(self.w + self.resize_drag_x*dx, self.min_width) end
        if self.resize_drag_y then self.h = math.max(self.h + self.resize_drag_y*dy, self.min_height) end
    end

    if not self.draggable then self.x, self.y = self.ix + self.resize_x, self.iy + self.resize_y end

    if self.resizing and self.input:released('left-click') then
        self.resizing = false
        self.resize_drag_x = nil
        self.resize_drag_y = nil
    end

    -- Set previous frame state
    self.resize_previous_mouse_position = {x = x, y = y}
end

return Resizable
