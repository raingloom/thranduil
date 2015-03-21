local TestTheme = {}

TestTheme.Button = {}
TestTheme.Button.draw = function(self)
    love.graphics.setColor(64, 64, 64)
    if self.hot then love.graphics.setColor(96, 96, 96) end
    if self.down then love.graphics.setColor(32, 32, 32) end
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    if self.selected then 
        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    end
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
    if self.selected then 
        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
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
    if self.selected then 
        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    end
end

TestTheme.Textarea = {}
TestTheme.Textarea.draw = function(self)
    -- Draw textinput background
    love.graphics.setColor(24, 24, 24)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    -- Draw text
    love.graphics.setColor(128, 128, 128)
    self.text:draw()

    if self.selected then 
        -- Draw selection
        love.graphics.setColor(192, 192, 192, 64)
        for i, _ in ipairs(self.selection_positions) do
            love.graphics.rectangle('fill', self.selection_positions[i].x, self.selection_positions[i].y, self.selection_sizes[i].w, self.selection_sizes[i].h)
        end

        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    end

    -- Unset stuff
    love.graphics.setColor(255, 255, 255, 255)
end

TestTheme.Scrollarea = {}
TestTheme.Scrollarea.draw = function(self)
    -- Draw scrollarea frame
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    if self.selected then 
        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x + self.x_offset, self.y + self.y_offset, self.area_width, self.area_height)
    end

    -- Draw scrollbars background
    love.graphics.setScissor()
    love.graphics.setColor(16, 16, 16)
    if self.show_scrollbars then
        if self.vertical_scrolling then
            love.graphics.rectangle('fill', self.x + self.x_offset + self.area_width, self.y + self.y_offset + self.scroll_button_height, 
                                            self.scroll_button_width, self.area_height - 2*self.scroll_button_height)
        end
        if self.horizontal_scrolling then
            love.graphics.rectangle('fill', self.x + self.x_offset + self.scroll_button_width, self.y + self.y_offset + self.area_height, 
                                            self.area_width - 2*self.scroll_button_width, self.scroll_button_height)
        end
    end
end

TestTheme.Frame = {}
TestTheme.Frame.draw = function(self)
    -- Draw frame
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)

    -- Draw resize border
    if self.resizable then
        love.graphics.setColor(16, 16, 16)
        if self.resize_hot then love.graphics.setColor(48, 48, 48) end
        if self.resizing then love.graphics.setColor(40, 40, 40) end
        love.graphics.rectangle('fill', self.x, self.y, self.w, self.resize_margin)
        love.graphics.rectangle('fill', self.x, self.y + self.h - self.resize_margin, self.w, self.resize_margin)
        love.graphics.rectangle('fill', self.x, self.y, self.resize_margin, self.h)
        love.graphics.rectangle('fill', self.x + self.w - self.resize_margin, self.y, self.resize_margin, self.h)
    end

    -- Draw drag bar
    if self.draggable then
        love.graphics.setColor(16, 16, 16)
        if self.drag_hot then love.graphics.setColor(48, 48, 48) end
        if self.dragging then love.graphics.setColor(40, 40, 40) end
        love.graphics.rectangle('fill', self.x + (self.resize_margin or 0), self.y + (self.resize_margin or 0), 
                                self.w - 2*(self.resize_margin or 0), self.drag_margin)
    end

    if self.selected then 
        love.graphics.setColor(128, 32, 32) 
        love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
    end
end

return TestTheme
