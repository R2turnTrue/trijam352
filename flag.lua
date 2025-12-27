Flag = Object:extend()
flag_sprite = love.graphics.newImage("assets/sprites/flag.png")
flag_sprite_cap = love.graphics.newImage("assets/sprites/flag_cap.png")

function Flag:new(x, y)
    self.x = x
    self.y = y
    self.width = flag_sprite:getWidth()
    self.height = flag_sprite:getHeight()
end

function Flag:getRect()
    return {
        x = self.x + 4,
        y = self.y + 3,
        w = 8,
        h = 13
    }
end

function Flag:draw()
    if Gameplay.clear then
        love.graphics.draw(flag_sprite_cap, self.x, self.y)
        return
    end
    love.graphics.draw(flag_sprite, self.x, self.y)
end