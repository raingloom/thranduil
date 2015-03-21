local Chatbox = UI.Object:extend('Chatbox')

-- This example creates a chatbox using 2 textareas and 1 scrollarea.
-- It uses Classic as the OOP library but here you could use any other thing...
-- The main thing that this does is take the input from one textarea (the one 
-- where the user types things) and paste it into the other (the chat). On top of
-- that it coordinates the chat textarea's size with the scrollarea so that the 
-- chat's text scrolling is done properly.

function Chatbox:new(x, y, w, h)
    local font = love.graphics.newFont('OpenSans-Regular.ttf', 14)
    self.main_frame = UI.Frame(x, y, w, h, {extensions = {TestTheme.Frame}, draggable = true, drag_margin = 12})

    self.scrollarea = UI.Scrollarea(5, 18, w - 26, h - 60, {extensions = {TestTheme.Scrollarea}, scrollbar_button_extensions = {TestTheme.Button}, 
                                                            area_width = w - 26, area_height = h - 60, dynamic_scroll_set = true, show_scrollbars = true})
    self.textarea = UI.Textarea(0, 0, w - 10, h - 60, {extensions = {TestTheme.Textarea}, font = font, text_margin = 3, editing_locked = true})
    self.scrollarea:addElement(self.textarea)
    self.main_frame:addElement(self.scrollarea)

    self.textinput = UI.Textarea(5, h - 36, w - 50, h, {extensions = {TestTheme.Textarea}, single_line = true, font = font, text_margin = 3})
    self.main_frame:addElement(self.textinput)

    self.send_button = UI.Button(w - 40, h - 36, 35, 30, {extensions = {TestTheme.Button}})
    self.main_frame:addElement(self.send_button)
end

function Chatbox:update(dt)
    if self.textinput.input:pressed('key-enter') or self.send_button.pressed then
        local text = self.textinput.text.text
        if #text > 0 then
            -- Add textinput's text to the textarea
            local chat_text = os.date("%H:%M") .. ': ' .. text .. '@n'
            self.textarea:addText(chat_text)

            -- Scrolling
            if self.textarea:getMaxLines()*self.textarea.font:getHeight() > self.scrollarea.area_height then
                self.scrollarea.h = self.textarea:getMaxLines()*self.textarea.font:getHeight() + 4*self.textarea.text_margin
                self.textarea.h = self.textarea:getMaxLines()*self.textarea.font:getHeight() + 4*self.textarea.text_margin
                for i = 1, 100 do self.scrollarea:scrollDown(1) end
            end

            -- Delete textinput's text
            self.textinput:selectAll()
            self.textinput:delete()
        end
    end

    -- Something to keep in mind: if you're gonna check if some input binding was pressed/released, you need to update
    -- the elements you're checking last and do the checking first, otherwise it doesn't work.
    self.main_frame:update(dt)
end

function Chatbox:draw()
    self.main_frame:draw()
end

return Chatbox
