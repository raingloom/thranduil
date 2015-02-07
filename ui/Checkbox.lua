local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox.new(ui, x, y, w, h, settings)
    local self = {}

    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Checkbox'

    self.ix, self.iy = x, y
    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind(' ', 'check-toggle')
    self.input:bind('mouse1', 'left-click')

    self.hot = false
    self.selected = false
    self.down = false 
    self.pressed = false
    self.released = false
    self.enter = false
    self.exit = false
    self.selected_enter = false
    self.selected_exit = false
    self.checked_enter = false
    self.checked_exit = false

    self.pressing = false
    self.previous_hot = false
    self.previous_selected = false
    self.previous_checked = false

    self.checked = false

    -- Initialize extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.new then extension.new(self) end
    end

    return setmetatable(self, Checkbox)
end

function Checkbox:update(dt, parent)
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

    -- Check for selected_enter
    if self.selected and not self.previous_selected then
        self.selected_enter = true
    else self.selected_enter = false end

    -- Check for selected_exit
    if not self.selected and self.previous_selected then
        self.selected_exit = true
    else self.selected_exit = false end

    -- Check for checked_enter
    if self.checked and not self.previous_checked then
        self.checked_enter = true
    else self.checked_enter = false end

    -- Check for checked_exit
    if not self.checked and self.previous_checked then
        self.checked_exit = true
    else self.checked_exit = false end

    -- Check for pressed/released/down on mouse hover
    if self.hot and self.input:pressed('left-click') then
        self.pressed = true
        self.pressing = true
    end
    if self.pressing and self.input:down('left-click') then
        self.down = true
    end
    if self.pressing and self.input:released('left-click') then
        self.released = true
        self.pressing = false
        self.down = false
    end

    -- Check for pressed/released/down on key press
    if self.selected and self.input:pressed('check-toggle') then
        self.pressed = true
        self.pressing = true
    end
    if self.pressing and self.input:down('check-toggle') then
        self.down = true
    end
    if self.pressing and self.input:released('check-toggle') then
        self.released = true
        self.pressing = false
        self.down = false
    end

    if self.pressed and self.previous_pressed then self.pressed = false end
    if self.released and self.previous_released then self.released = false end

    -- Change state
    if self.released and (self.hot or self.selected) then
        self.checked = not self.checked
    end

    -- Update extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.update then extension.update(self, dt, parent) end
    end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_pressed = self.pressed
    self.previous_released = self.released
    self.previous_selected = self.selected
    self.previous_checked = self.checked

    self.input:update(dt)
end

function Checkbox:draw()
    -- Draw extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.draw then extension.draw(self) end
    end
end

return setmetatable({new = new}, {__call = function(_, ...) return Checkbox.new(...) end})
