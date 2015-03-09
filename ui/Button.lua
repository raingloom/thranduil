local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Base = require(ui_path .. 'Base')
local Button = Object:extend('Button')
local Draggable = require(ui_path .. 'Draggable')
local Resizable = require(ui_path .. 'Resizable')
Button:implement(Base)
Button:implement(Draggable)
Button:implement(Resizable)

function Button:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Button'

    self:baseNew(x, y, w, h, settings)

    self.draggable = settings.draggable or false
    if self.draggable then self:draggableNew(settings) end
    self.resizable = settings.resizable or false
    if self.resizable then self:resizableNew(settings) end
end

function Button:update(dt, parent)
    if parent then 
        if parent.type == 'Frame' and self.annotation == "Frame's close button" then
            self.ix = parent.w - parent.close_margin - parent.close_button_width
            self.iy = parent.close_margin
        end
    end
    self:basePreUpdate(dt, parent)
    if self.resizable then self:resizableUpdate(dt) end
    if self.draggable then self:draggableUpdate(dt) end
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
