local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Closeable = Object:extend('Closeable')

function Closeable:closeableNew(settings)
    local settings = settings or {}
    self.closing = false
    self.closed = settings.closed or false
    self.close_margin = settings.close_margin or 5
    self.close_button_width = settings.close_button_width or 10
    self.close_button_height = settings.close_button_height or 10
    self.close_button = self.ui.Button(self.w - self.close_margin - self.close_button_width, self.close_margin, self.close_button_width, self.close_button_height,
                                      {extensions = settings.close_button_extensions or {}, annotation = settings.annotation})
    self:bind('escape', 'close')
end

function Closeable:closeableUpdate(dt)
    if self.close_button.pressed then
        self.closing = true
    end
    if self.closing and self.close_button.released then
        self.closed = true
        self.closing = false
    end
    local any_selected = false
    for _, element in ipairs(self.elements) do
        if element.selected then any_selected = true end
    end
    if self.selected and not any_selected and self.input:pressed('close') then
        self.closed = true
    end
    self.close_button:update(dt, self)
end

function Closeable:closeableDraw()
    self.close_button:draw()
end

return Closeable
