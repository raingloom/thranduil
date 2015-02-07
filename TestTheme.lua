local TestTheme = {}

TestTheme.Button = {}
TestTheme.Button.draw = function(self)
    love.graphics.setColor(64, 64, 64)
    if self.hot then love.graphics.setColor(96, 96, 96) end
    if self.down then love.graphics.setColor(32, 32, 32) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
end

TestTheme.Checkbox = {}
TestTheme.Checkbox.draw = function(self)
    love.graphics.setColor(64, 64, 64)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    if self.hot then 
        love.graphics.setColor(96, 96, 96) 
        love.graphics.rectangle('fill', self.x + self.w/6, self.y + self.h/6, 4*self.w/6, 4*self.h/6)
    end

    if self.checked then
        love.graphics.setColor(128, 128, 128) 
        love.graphics.rectangle('fill', self.x + self.w/6, self.y + self.h/6, 4*self.w/6, 4*self.h/6)
    end
end

TestTheme.Slider = {}
TestTheme.Slider.draw = function(self)
    love.graphics.setColor(64, 64, 64)
    if self.hot then love.graphics.setColor(96, 96, 96) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    love.graphics.setColor(48, 48, 48)
    if self.down then love.graphics.setColor(32, 32, 32) end
    love.graphics.rectangle('fill', self.x, self.y, self.slider_x - self.x, self.h)
end

TestTheme.Frame = {}
TestTheme.Frame.draw = function(self)
    -- Draw frame
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    -- Draw resize border
    if self.resizable then
        love.graphics.setColor(32, 32, 32)
        if self.resize_hot then love.graphics.setColor(48, 48, 48) end
        if self.resizing then love.graphics.setColor(16, 16, 16) end
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.resize_margin)
        love.graphics.rectangle('fill', self.x, self.y + self.h - self.resize_margin, self.w, self.resize_margin)
        love.graphics.rectangle('fill', self.x, self.y, self.resize_margin, self.h)
        love.graphics.rectangle('fill', self.x + self.w - self.resize_margin, self.y, self.resize_margin, self.h)
    end

    -- Draw drag bar
    if self.draggable then
        love.graphics.setColor(32, 32, 32)
        if self.drag_hot then love.graphics.setColor(48, 48, 48) end
        if self.dragging then love.graphics.setColor(16, 16, 16) end
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.drag_margin)
    end
end

return TestTheme
