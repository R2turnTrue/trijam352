Particle = Object:extend()

function Particle:new(x, y, vx, vy, lifetime, radius, gravity, col_r, col_g, col_b, col_a)
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.lifetime = lifetime
    self.age = 0
    self.should_remove = false

    self.radius = radius or 2

    self.gravity = gravity or 0

    self.col_r = col_r or 1.0
    self.col_g = col_g or 1.0
    self.col_b = col_b or 1.0
    self.col_a = col_a or 1.0
end

function Particle:update(dt)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    self.vy = self.vy + self.gravity * dt

    self.age = self.age + dt

    if self:isExpired() then
        self.should_remove = true
    end
end

function Particle:isExpired()
    return self.age >= self.lifetime
end

function Particle:draw()
    --love.graphics.setColor(self.col_r, self.col_g, self.col_b, self.col_a * (1.0 - self.age / self.lifetime))
    love.graphics.setColor(self.col_r, self.col_g, self.col_b, self.col_a)
    love.graphics.circle("fill", self.x, self.y,
        self.radius * (1.0 - self.age / self.lifetime))

    love.graphics.setColor(1, 1, 1, 1)
end