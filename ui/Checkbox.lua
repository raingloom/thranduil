local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Base = require(ui_path .. 'Base')
local Checkbox = Object:extend('Checkbox')
Checkbox:implement(Base)

function Checkbox:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Checkbox'

    self:baseNew(x, y, w, h, settings)

    self.checked_enter = false
    self.checked_exit = false
    self.checked = false
    self.previous_checked = false
end

function Checkbox:update(dt, parent)
    self:basePreUpdate(dt, parent)

    -- Check for checked_enter
    if self.checked and not self.previous_checked then
        self.checked_enter = true
    else self.checked_enter = false end

    -- Check for checked_exit
    if not self.checked and self.previous_checked then
        self.checked_exit = true
    else self.checked_exit = false end

    self:basePostUpdate(dt)

    -- Change state
    if self.released and (self.hot or self.selected) then
        self.checked = not self.checked
    end

    self.previous_checked = self.checked
end

function Checkbox:draw()
    self:baseDraw()
end

function Checkbox:toggle()
    self.checked = not self.checked
end

return Checkbox
