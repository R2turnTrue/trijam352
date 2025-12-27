Camera = Object:extend()

function Camera:new(x, y)
    self.x = x or 0
    self.y = y or 0
    self.rotation = 0

    self.shake_amplitude = 0
    self.shake_duration = 0
    self.shake_x = 0
    self.shake_y = 0
end

function Camera:start()
    love.graphics.push()

    local cx, cy = push._WWIDTH / 2.0, push._WHEIGHT / 2.0
    local cx_rot = cx * math.cos(self.rotation) - cy * math.sin(self.rotation)
    local cy_rot = cy * math.cos(self.rotation) + cx * math.sin(self.rotation)

    love.graphics.rotate(-self.rotation)
    love.graphics.translate(cx_rot - cx, cy_rot - cy)
    love.graphics.translate(-self.x + self.shake_x, -self.y + self.shake_y)
end

function Camera:update(dt)
    if self.shake_duration > 0 then
        self.shake_duration = self.shake_duration - dt
        self.shake_x = (math.random() * 2 - 1) * self.shake_amplitude
        self.shake_y = (math.random() * 2 - 1) * self.shake_amplitude
    else
        self.shake_amplitude = 0
        self.shake_duration = 0
        self.shake_x = 0
        self.shake_y = 0
    end
end

function Camera:shake(amplitude, duration)
    self.shake_amplitude = amplitude
    self.shake_duration = duration
end

function Camera:finish()
    love.graphics.pop()
end

function Camera:screen_to_world(x, y)
    return (x * (push._WWIDTH / push._RWIDTH)) + self.x, (y * (push._WHEIGHT / push._RHEIGHT)) + self.y
end

function Camera:screen_to_world_no_cam_pos(x, y)
    return (x * (push._WWIDTH / push._RWIDTH)), (y * (push._WHEIGHT / push._RHEIGHT))
end