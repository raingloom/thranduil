local ui_path = tostring(...):sub(1, -10)
local Object = require(ui_path .. 'classic/classic')
local Container = Object:extend('Container')

function Container:containerNew(settings)
    local settings = settings or {}

    self:bind('tab', 'focus-next')
    self:bind('lshift', 'previous-modifier')
    self:bind('escape', 'unselect')
    self:bind('left', 'focus-left')
    self:bind('right', 'focus-right')
    self:bind('up', 'focus-up')
    self:bind('down', 'focus-down')

    self.elements = {}
    self.currently_focused_element = nil
    self.any_selected = false
end

function Container:containerUpdate(dt, parent)
    -- Focus on elements
    if self.selected and not self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusNext() end
    if self.selected and self.input:down('previous-modifier') and self.input:pressed('focus-next') then self:focusPrevious() end
    if self.selected and self.input:pressed('focus-left') then self:focusDirection('left') end
    if self.selected and self.input:pressed('focus-right') then self:focusDirection('right') end
    if self.selected and self.input:pressed('focus-up') then self:focusDirection('up') end
    if self.selected and self.input:pressed('focus-down') then self:focusDirection('down') end
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
        for _, element in ipairs(self.elements) do
            element.selected = false
        end
    end

    -- Unselect on escape
    self.any_selected = false
    if self.selected then
        for _, element in ipairs(self.elements) do
            if element.selected then self.any_selected = true end
        end
        if self.input:pressed('unselect') then self:unselect() end
    end

    -- Update children
    if self.type == 'Scrollarea' then
        for _, element in ipairs(self.elements) do
            if element.inside_scroll_area then
                element.inside_scroll_area = nil
                element:update(dt, self)
            end
        end
    else 
        for _, element in ipairs(self.elements) do 
            element:update(dt, self) 
        end 
    end
end

function Container:containerDraw()
    for _, element in ipairs(self.elements) do element:draw() end
end

function Container:containerAddElement(element)
    element.parent = self
    table.insert(self.elements, element)
    element:update(0, self)
    return element
end

function Container:focusNext()
    for _, element in ipairs(self.elements) do if element.any_selected then return end end
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

function Container:focusPrevious()
    for _, element in ipairs(self.elements) do if element.any_selected then return end end
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

function Container:focusDirection(direction)
    for _, element in ipairs(self.elements) do if element.any_selected then return end end
    for i, element in ipairs(self.elements) do 
        if element.selected then self.currently_focused_element = i end
        element.selected = false 
    end
    if self.currently_focused_element then
        local angled = function(a, b) local d = math.abs(a - b) % 360; if d > 180 then return 360 - d else return d end end
        local angles = {right = 0, left = -180, up = -90, down = 90}
        local min, j, n = 10000, nil, 0
        local selected_element = self.elements[self.currently_focused_element]
        for i, element in ipairs(self.elements) do
            if i ~= self.currently_focused_element then
                local d = math.sqrt(math.pow(selected_element.x - element.x, 2) + math.pow(selected_element.y - element.y, 2))
                local v = math.max(angled(math.deg(math.atan2(element.y - selected_element.y, element.x - selected_element.x)), angles[direction]), 20)*d
                if direction == 'right' then if element.x > selected_element.x then n = n + 1 end end
                if direction == 'left' then if element.x < selected_element.x then n = n + 1 end end
                if direction == 'up' then if element.y < selected_element.y then n = n + 1 end end
                if direction == 'down' then if element.y > selected_element.y then n = n + 1 end end
                if v <= min then min = v; j = i end
            end
        end
        -- Loop over
        if n == 0 then
            if direction == 'left' or direction == 'right' then
                max_dx, min_dy, j = -10000, 10000, nil
                for i, element in ipairs(self.elements) do
                    if i ~= self.currently_focused_element then
                        local dx, dy = math.abs(selected_element.x - element.x), math.abs(selected_element.y - element.y)
                        if dx > max_dx or dy < min_dy then
                            max_dx = dx
                            min_dy = dy
                            j = i
                        end
                    end
                end
                if j then self.currently_focused_element = j end
            elseif direction == 'up' or direction == 'down' then
                min_dx, max_dy, j = 10000, -10000, nil
                for i, element in ipairs(self.elements) do
                    if i ~= self.currently_focused_element then
                        local dx, dy = math.abs(selected_element.x - element.x), math.abs(selected_element.y - element.y)
                        if dx < min_dx or dy > max_dy then
                            min_dx = dx
                            max_dy = dy
                            j = i
                        end
                    end
                end
                if j then self.currently_focused_element = j end
            end

        -- Normal behavior
        elseif n > 0 and j then self.currently_focused_element = j end
    else self.currently_focused_element = 1 end
end

function Container:unselect()
    for _, element in ipairs(self.elements) do if element.any_selected then return end end
    if self.any_selected then
        for _, element in ipairs(self.elements) do
            element.selected = false
            self.currently_focused_element = nil
        end
    else self.selected = false end
end

return Container
