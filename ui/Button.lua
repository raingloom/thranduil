local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Base = require(ui_path .. 'Base')
local Button = Object:extend('Button')
Button:implement(Base)

function Button:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Button'

    self:baseNew(x, y, w, h, settings)
end

function Button:update(dt, parent)
    if parent then 
        if parent.type == 'Frame' and self.annotation == "Frame's close button" then
            self.ix = parent.w - parent.close_margin - parent.close_button_width
            self.iy = parent.close_margin
        end
    end
    self:basePreUpdate(dt, parent)
    self:basePostUpdate(dt)
end

function Button:draw()
    self:baseDraw()
end

function Button:press()
    self.pressed = true
    self.released = true
end

return Button
