local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Textarea = Object:extend('Textarea')
local Draggable = require(ui_path .. 'Draggable')
local Resizable = require(ui_path .. 'Resizable')
Textarea:implement(Base)
Textarea:implement(Draggable)
Textarea:implement(Resizable)

function Textarea:new(ui, x, y, w, h, settings)
    self.ui = ui
    self.id = self.ui.addToElementsList(self)
    self.type = 'Textarea'

    self:basePreNew(x, y, w, h, settings)

    self.draggable = settings.draggable or false
    if self.draggable then self:draggableNew(settings) end
    self.resizable = settings.resizable or false
    if self.resizable then self:resizableNew(settings) end

    self:basePostNew()
end

function Textarea:update(dt, parent)
    self:basePreUpdate(dt, parent)
    if self.resizable then self:resizableUpdate(dt) end
    if self.draggable then self:draggableUpdate(dt) end
    self:basePostUpdate(dt)
end

function Textarea:draw()
    self:baseDraw()
end

return Textarea
