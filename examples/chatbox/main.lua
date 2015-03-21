TestTheme = require 'TestTheme'
UI = require 'ui/UI'
Chatbox = require 'Chatbox'

function love.load()
    UI.registerEvents()
    
    chatbox = Chatbox(10, 380, 300, 210)
end

function love.update(dt)
    chatbox:update(dt)
end

function love.draw()
    chatbox:draw()
end
