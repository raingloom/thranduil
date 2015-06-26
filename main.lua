UI = require 'ui/UI'
TestTheme = require 'TestTheme'

function love.load()
    UI.registerEvents()

    math.randomseed(os.time())

    frame = UI.Frame(105, 105, 155, 155, {extensions = {TestTheme.Frame}, auto_align = true, auto_spacing = 5, auto_margin = 5})
    --[[
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    frame:addElement(UI.Button(0, 0, 25, 25, {extensions = {TestTheme.Button}}))
    ]]--
end

function love.update(dt)
    frame:update(dt)
end

function love.draw()
    frame:draw()
end

function love.keypressed(key)
    if key == ' ' then
        frame:addElement(UI.Button(0, 0, math.random(15, 50), math.random(15, 25), {extensions = {TestTheme.Button}}))
    end
    
end
