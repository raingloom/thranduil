local ui_path = (...):sub(1, (...):find('/'))
local Object = require(ui_path .. 'classic/classic')
local Base = require(ui_path .. 'Base')
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
    self:bind('mouse1', 'left-click')
    self:bind('left', 'move-left')
    self:bind('right', 'move-right')
    self:bind('up', 'move-up')
    self:bind('down', 'move-down')
    self:bind('lshift', 'lshift')
    self:bind('backspace', 'backspace')
    self:bind('delete', 'delete')
    self:bind('lctrl', 'lctrl')
    self:bind('home', 'first')
    self:bind('end', 'last')
    self:bind('x', 'cut')
    self:bind('c', 'copy')
    self:bind('v', 'paste')
    self:bind('a', 'all')

    self.single_line = settings.single_line
    self.text_margin = settings.text_margin or 5
    self.wrap_width = settings.wrap_width or (self.w - 4*self.text_margin)
    self.text_x, self.text_y = self.x + self.text_margin, self.y + self.text_margin
    self.text_ix, self.text_iy = self.text_x, self.text_y
    self.text_base_x, self.text_base_y = self.text_x, self.text_y

    self.font = settings.font or love.graphics.getFont()
    self.text_table = {}
    self.copy_buffer = {}
    self.index = 1
    self.selection_index = nil
    self.selection_positions = {}
    self.selection_sizes = {}
    self.key_pressed_time = 0
    self.mouse_all_selected = false
    self.mouse_pressed_time = false
    self.last_mouse_pressed_time = false

    self.text_settings = {font = self.font, wrap_width = self.wrap_width, justify = true}
    self.text = self.ui.Text(self.text_x, self.text_y, self:join(), self.text_settings) 

    self.draggable = settings.draggable or false
    if self.draggable then self:draggableNew(settings) end
    self.resizable = settings.resizable or false
    if self.resizable then self:resizableNew(settings) end

    self:basePostNew()
end

function Textarea:update(dt, parent)
    self:basePreUpdate(dt, parent)
    if parent then self.text_base_x, self.text_base_y = parent.x + self.text_ix, parent.y + self.text_iy end
    self.text_x, self.text_y = self.text_base_x + (self.text_margin or 0), self.text_base_y + (self.text_margin or 0)
    if self.resizable then self:resizableUpdate(dt) end
    if self.draggable then self:draggableUpdate(dt) end

    self.text.x, self.text.y = self.text_x, self.text_y
    self.text:update(dt)

    -- Figure out selection/cursor position in pixels
    local u, v, w
    local line_string = self:getLineString(self:getIndexLine(self.index) or self:getIndexLine(self.index - 1))
    local line_first_index = self:getIndexOfFirstInLine(self:getIndexLine(self.index)) or 1
    local u = self.text.font:getWidth(line_string:utf8sub(1, self.index - line_first_index))
    local v = self.text.font:getWidth(line_string:utf8sub(1, self.index - line_first_index + 1))
    --if self.selection_index then v = self.font:getWidth(self.text.text:utf8sub(1, self.selection_index - 1)) end
    if self.index == #self.text_table + 1 and not self.selection_index then v = v + self.text.font:getWidth('a') end
    self.selection_positions = {{x = self.text_x + u, y = self.text_y + (self:getIndexLine(self.index) or self:getIndexLine(self.index - 1) or 0)*self.font:getHeight()}}
    self.selection_sizes = {{w = v - u, h = self.font:getHeight()}}

    -- Everything up has to happen every frame if the textarea is selected or not
    if not self.selected then return end
    -- Everything down has to happen only if the textarea is selected
    
    -- Move cursor left
    if not self.input:down('lshift') and self.input:pressed('move-left') then
        self.key_pressed_time = love.timer.getTime()
        self:moveLeft()
    end
    if not self.input:down('lshift') and self.input:down('move-left') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:moveLeft() end
    end

    -- Move cursor right
    if not self.input:down('lshift') and self.input:pressed('move-right') then
        self.key_pressed_time = love.timer.getTime()
        self:moveRight()
    end
    if not self.input:down('lshift') and self.input:down('move-right') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:moveRight() end
    end

    -- Move cursor up
    if not self.input:down('lshift') and self.input:pressed('move-up') then
        self.key_pressed_time = love.timer.getTime()
        self:moveUp()
    end
    if not self.input:down('lshift') and self.input:down('move-up') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:moveUp() end
    end

    -- Move cursor down
    if not self.input:down('lshift') and self.input:pressed('move-down') then
        self.key_pressed_time = love.timer.getTime()
        self:moveDown()
    end
    if not self.input:down('lshift') and self.input:down('move-down') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:moveDown() end
    end

    -- Move cursor to beginning
    if self.input:pressed('first') then self:first() end

    -- Move cursor to end
    if self.input:pressed('last') then self:last() end

    -- Select left
    if self.input:down('lshift') and self.input:pressed('move-left') then
        self.key_pressed_time = love.timer.getTime()
        self:selectLeft()
    end
    if self.input:down('lshift') and self.input:down('move-left') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:selectLeft() end
    end

    -- Select right
    if self.input:down('lshift') and self.input:pressed('move-right') then
        self.key_pressed_time = love.timer.getTime()
        self:selectRight()
    end
    if self.input:down('lshift') and self.input:down('move-right') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:selectRight() end
    end

    -- Select up
    if self.input:down('lshift') and self.input:pressed('move-up') then
        self.key_pressed_time = love.timer.getTime()
        self:selectUp()
    end
    if self.input:down('lshift') and self.input:down('move-up') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:selectUp() end
    end

    -- Select down
    if self.input:down('lshift') and self.input:pressed('move-down') then
        self.key_pressed_time = love.timer.getTime()
        self:selectDown()
    end
    if self.input:down('lshift') and self.input:down('move-down') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:selectDown() end
    end

    -- Select all
    if self.input:down('lctrl') and self.input:pressed('all') then self:selectAll() end

    -- Delete before cursor
    if self.input:pressed('backspace') then
        self.key_pressed_time = love.timer.getTime()
        self:backspace()
    end
    if self.input:down('backspace') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:backspace() end
    end

    -- Delete after cursor
    if self.input:pressed('delete') then
        self.key_pressed_time = love.timer.getTime()
        self:delete()
    end
    if self.input:down('delete') then
        if love.timer.getTime() - self.key_pressed_time > 0.2 then self:delete() end
    end

    self:basePostUpdate(dt)
end

function Textarea:draw()
    love.graphics.setStencil(function() love.graphics.rectangle('fill', self.x, self.y, self.w, self.h) end)
    self:baseDraw()
    love.graphics.setStencil()
end

function Textarea:updateText()
    self.text = self.ui.Text(self.text_x, self.text_y, self:join(), self.text_settings)
end

function Textarea:textinput(text)
    if not self.selected then return end
    table.insert(self.text_table, self.index, text)
    self.index = self.index + 1
    self:updateText()
end

function Textarea:join(table)
    local table = table or self.text_table
    local string = ''
    for i, c in ipairs(table) do string = string .. c end
    return string
end

function Textarea:getLineString(line)
    local string = ''
    for i, c in ipairs(self.text.characters) do
        if c.line == line then string = string .. c.character end
    end
    return string
end

function Textarea:getIndexLine(index)
    for i, c in ipairs(self.text.characters) do
        if i == index then return c.line end
    end
end

function Textarea:getIndexOfFirstInLine(line)
    for i, c in ipairs(self.text.characters) do
        if c.line == line then return i end
    end
end

function Textarea:getMaxLines()
    local n_lines = 0
    for i, c in ipairs(self.text.characters) do n_lines = c.line + 1 end
    return n_lines
end

function Textarea:deleteSelected()
    if not self.selection_index then return end
    if self.index == self.selection_index then return end
    local min, max = 0, 0
    if self.index < self.selection_index then min = self.index; max = self.selection_index - 1
    elseif self.selection_index < self.index then min = self.selection_index; max = self.index - 1 end
    for i = max, min, -1 do table.remove(self.text_table, i) end
    self.index = min
    self.selection_index = nil
end

function Textarea:moveLeft()
    self.index = self.index - 1
    self.selection_index = nil
    if self.index < 1 then self.index = 1 end
end

function Textarea:moveRight()
    self.index = self.index + 1
    self.selection_index = nil
    if self.index > #self.text_table + 1 then self.index = #self.text_table + 1 end
end

function Textarea:moveUp()
    local index_line = self:getIndexLine(self.index) or self:getIndexLine(self.index - 1)
    if index_line == 0 then self.index = 1; return end
    local line_first_index = self:getIndexOfFirstInLine(self:getIndexLine(self.index)) or 1
    local w = self.text.font:getWidth(self:getLineString(index_line):utf8sub(1, self.index - line_first_index))
    local string = ''
    for i, c in ipairs(self.text.characters) do
        if c.line == index_line - 1 then
            string = string .. c.character
            local lw = self.text.font:getWidth(string)
            if lw >= w then self.index = i + 1; return end
        end
    end
end

function Textarea:moveDown()
    local index_line = self:getIndexLine(self.index) or self:getIndexLine(self.index - 1)
    if index_line == self:getMaxLines() - 1 then self.index = #self.text.characters; return end
    local line_first_index = self:getIndexOfFirstInLine(self:getIndexLine(self.index)) or 1
    local w = self.text.font:getWidth(self:getLineString(index_line):utf8sub(1, self.index - line_first_index))
    local string = ''
    for i, c in ipairs(self.text.characters) do
        if c.line == index_line + 1 then
            string = string .. c.character
            local lw = self.text.font:getWidth(string)
            if lw >= w then self.index = i + 1; return end
        end
    end
end

return Textarea
