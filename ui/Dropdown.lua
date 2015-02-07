local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new()
    local self = {}

    return setmetatable(self, Dropdown)
end

function Dropdown:update(dt)

end

function Dropdown:draw()

end

return setmetatable({new = new}, {__call = function(_, ...) return Dropdown.new(...) end})
