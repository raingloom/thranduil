local Object = require((...):sub(1, (...):find('/')) .. 'classic/classic')
local Slider = Object:extend('Slider')

function Slider:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Slider'

    self.ix, self.iy = x, y
    self.x, self.y = x, y
    self.w, self.h = w, h
    local settings = settings or {}
    for k, v in pairs(settings) do self[k] = v end

    self.input = self.ui.Input()
    self.input:bind('mouse1', 'left-click')
    self.input:bind('left', 'move-left')
    self.input:bind('right', 'move-right')

    self.hot = false
    self.selected = false
    self.down = false
    self.pressed = false
    self.released = false
    self.enter = false
    self.exit = false
    self.selected_enter = false
    self.selected_exit = false

    self.value = settings.value or 0
    self.value_interval = settings.value_interval or 1
    self.max_value = settings.max_value or self.w
    self.min_value = settings.min_value or 0
    self.slider_x = ((self.value - self.min_value)/(self.max_value - self.min_value))*(self.w) + self.x 

    -- Initialize extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.new then extension.new(self) end
    end
end

function Slider:update(dt, parent)
    local x, y = love.mouse.getPosition()
    if parent then
        self.x, self.y = parent.x + self.ix, parent.y + self.iy
    end

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

    -- Check for move left/right
    if self.selected and self.input:pressed('move-left') then
        self.pressed_time = love.timer.getTime()
        self:moveLeft()
    end
    if self.selected and self.input:down('move-left') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then self:moveLeft() end
    end
    if self.selected and self.input:pressed('move-right') then
        self.pressed_time = love.timer.getTime()
        self:moveRight()
    end
    if self.selected and self.input:down('move-right') then
        local d = love.timer.getTime() - self.pressed_time
        if d > 0.2 then self:moveRight() end
    end

    -- Change value
    if self.hot and self.down then
        self.value = ((x - self.x)/(self.w))*(self.max_value - self.min_value) + self.min_value
        self.value = self.value_interval*math.ceil(self.value/self.value_interval)
    end

    self.slider_x = ((self.value - self.min_value)/(self.max_value - self.min_value))*(self.w) + self.x 

    -- Update extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.update then extension.update(self, dt, parent) end
    end

    -- Set previous frame state
    self.previous_hot = self.hot
    self.previous_selected = self.selected

    self.input:update(dt)
end

function Slider:draw()
    -- Draw extensions
    for _, extension in ipairs(self.extensions or {}) do
        if extension.draw then extension.draw(self) end
    end
end

function Slider:moveLeft()
    self.value = math.max(self.value - self.value_interval, self.min_value)
end

function Slider:moveRight()
    self.value = math.min(self.value + self.value_interval, self.max_value)
end

return Slider

