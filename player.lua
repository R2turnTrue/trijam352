Player = Object.extend(Object)
GhostPlayer = Object.extend(Object)

function Player:new(x, y)
    self.x = x
    self.y = y
    self.gravity = 800

    self.velocity_x = 0.0
    self.velocity_y = 0.0

    self.max_speed = 100
    self.acceleration = self.max_speed * (1/0.07) -- 0.07초 안에 최대속도
    self.deceleration = self.max_speed * (1/0.1) -- 0.1초 안에 정지

    self.last_direction = 1.0

    self.jump_force = 250

    self.is_ground = false
    self.prev_is_ground = false

    self.image = love.graphics.newImage("assets/sprites/player.png")

    self.footstep_timer = 0.0

    self.available_jumps = 2

    self.available_dashes = 1
    self.dash_timer = 0.0
    self.dash_ghost_timer = 0.0

    self.squash_x = 1.0
    self.squash_y = 1.0
    self.squash_ground_timer = 0.0

    self.ghosts = {}

    self.dash_sfx = love.audio.newSource("assets/sounds/dash.wav", "static")
    self.footstep_sfx = love.audio.newSource("assets/sounds/footstep.wav", "static")
    self.jump_sfx = love.audio.newSource("assets/sounds/jump.wav", "static")
    self.jump_sfx:setVolume(0.2)

    self.axis_x = 0.0
    self.last_spawnpoint_x = x
    self.last_spawnpoint_y = y
end

function Player:getRect(x, y)
    return {
        x = x + 2,
        y = y + 2,
        w = 12,
        h = 14
    }
end

function Player:move_and_slide(dt)
    local new_x = self.x + self.velocity_x * dt
    local new_bb = self:getRect(new_x, self.y)
    local collResult = tilemap:checkCollision(new_bb, true, true)

    while collResult do
        if self.velocity_x > 0 then
            -- move right
            new_x = collResult.x - new_bb.w - 0.01 - 2
        else
            -- move left
            new_x = collResult.x + collResult.w + 0.01 - 2
        end
        self.velocity_x = 0

        new_bb = self:getRect(new_x, self.y)
        collResult = tilemap:checkCollision(new_bb, true, true)
    end

    self.x = new_x

    local new_y = self.y + self.velocity_y * dt
    local new_bb = self:getRect(self.x, new_y)
    new_bb.h = new_bb.h-- + 2 -- 발끝 위치로 충돌 판정
    local collResult = tilemap:checkCollision(new_bb, true, true)

    if not collResult then
        --print("may not ground")
        self.is_ground = false
    end

    while collResult do
        if self.velocity_y > 0 then
            -- move down
            new_y = collResult.y - self.image:getHeight() - 0.01
            --print('ground')
            self.is_ground = true
        else
            -- move up
            new_y = collResult.y + collResult.h + 0.01
        end
        self.velocity_y = 0

        new_bb = self:getRect(self.x, new_y)
        new_bb.h = new_bb.h-- + 2 -- 발끝 위치로 충돌 판정
        collResult = tilemap:checkCollision(new_bb, true, true)
    end

    if new_y > tilemap.currentLevel.offset_y + tilemap.currentLevel.height - self.image:getHeight() then
        new_y = tilemap.currentLevel.offset_y + tilemap.currentLevel.height - self.image:getHeight()
        self.velocity_y = 0
        self.is_ground = true

        for i = 1, 20 do
            -- x
            -- y
            -- vx
            -- vy
            -- lifetime
            -- radius
            -- gravity
            -- col
            local p = Particle(self.x + self.image:getWidth() / 2,
                                self.y + self.image:getHeight() / 2,
                                math.random() * 10 - 5,
                                0.5 + math.random() * 3.5,
                                0.6,
                                1.0 + math.random() * 1.0,
                                0.0)
            table.insert(particles, p)
        end

        self.x = self.last_spawnpoint_x
        self.y = self.last_spawnpoint_y

        self.velocity_x = 0
        self.velocity_y = 0
        return
    end
    self.y = new_y
end

function Player:apply_gravity(dt)
    if self.dash_timer > 0.0 then
        return
    end

    self.velocity_y = self.velocity_y + self.gravity * dt
end

function Player:follow_camera(dt)
    local cam_x = self.x + self.image:getWidth() / 2 - push._WWIDTH / 2
    local cam_y = self.y + self.image:getHeight() / 2 - push._WHEIGHT / 2

    local level = tilemap.currentLevel
    local confine_x_min = level.offset_x
    local confine_x_max = level.offset_x + level.width - push._WWIDTH

    local confine_y_min = level.offset_y
    local confine_y_max = level.offset_y + level.height - push._WHEIGHT

    local x_lerp_speed = 5
    local y_lerp_speed = 5

    if cam_x < confine_x_min then
        cam_x = confine_x_min
        x_lerp_speed = 2
    elseif cam_x > confine_x_max then
        cam_x = confine_x_max
        x_lerp_speed = 2
    end

    if cam_y < confine_y_min then
        cam_y = confine_y_min
        y_lerp_speed = 2
    elseif cam_y > confine_y_max then
        cam_y = confine_y_max
        y_lerp_speed = 2
    end

    cam.x = lume.lerp(cam.x, cam_x, dt*x_lerp_speed)
    cam.y = lume.lerp(cam.y, cam_y, dt*y_lerp_speed)
end

function Player:footstep(dt)
    if not self.is_ground or (self.prev_is_ground and math.abs(self.velocity_x) < 0.1) then
        self.footstep_timer = 0.0
        return
    end

    self.footstep_timer = self.footstep_timer - dt

    if self.footstep_timer <= 0.0 then
        self.footstep_timer = 0.3
        self.footstep_sfx:play()

        self:emit_footstep()
    end
end

function Player:emit_footstep(spread_par, count_par)
    local foot_x = self.x + self.image:getWidth() / 2
    local foot_y = self.y + self.image:getHeight()

    local spread = spread_par or 10
    local count = count_par or 7

    for i = 1, count do
        -- x
        -- y
        -- vx
        -- vy
        -- lifetime
        -- radius
        -- gravity
        -- col
        local p = Particle(foot_x + math.random() * spread - spread / 2,
                            foot_y,
                            math.random() * 10 - 5,
                            0.5 + math.random() * 3.5,
                            0.6,
                            1.0 + math.random() * 1.0,
                            0.0)
        table.insert(particles, p)
    end
end

---function love.keypressed(k)
---    if k == "space" then
---        plr:handle_jump()
---    end

---    if k == "lshift" then
---        plr:handle_dash()
---    end
---end

function Player:handle_jump()
    --if self.is_ground or self.available_jumps > 0 then
    if true then
        self.velocity_y = -self.jump_force
        self.squash_x = 1
        self.squash_y = 1
        self.available_jumps = self.available_jumps - 1
        self.jump_sfx:play()

        if self.is_ground then
            -- 일반 점프
            self:emit_footstep()
            self.available_jumps = 1
        else
            -- 이중 점프
            self:emit_footstep(20, 30)
        end
    else
        print('jump not worked, ' .. tostring(self.is_ground) .. ', ' .. tostring(self.available_jumps))
    end
end

function Player:handle_dash()
    if self.available_dashes > 0 then
        self.velocity_x = 0
        self.velocity_y = 0
        self.dash_timer = 0.13
        self.dash_ghost_timer = 0.0

        self.available_dashes = self.available_dashes - 1

        self.dash_sfx:play()

        cam:shake(4, 0.05)
    end
end

function Player:update_dash(dt)
    if self.dash_timer > 0.0 then
        self.dash_timer = self.dash_timer - dt

        self.velocity_x = self.last_direction * 1000
        --self.velocity_x = self.velocity_x + self.last_direction * 300
        
        --if math.abs(self.velocity_x) > 1500 then
        --    self.velocity_x = self.last_direction * 500
        --end

        self.dash_ghost_timer = self.dash_ghost_timer - dt
        if self.dash_ghost_timer <= 0.0 then
            self.dash_ghost_timer = 0.03

            local ghost = GhostPlayer(self.x, self.y, self.squash_x, self.squash_y, self.last_direction)
            table.insert(self.ghosts, ghost)
        end
    end
end

function Player:horizontal_move(dt)
    if self.dash_timer > 0.0 then
        return
    end

    local axis_x = self.axis_x
    self.last_direction = lume.sign(axis_x)
    if self.last_direction == 0 then
        self.last_direction = 1
    end

    --if love.keyboard.isDown("a") then
        --axis_x = axis_x - 1
        --self.last_direction = -1
    --end

    --if love.keyboard.isDown("d") then
        --axis_x = axis_x + 1
        --self.last_direction = 1
    --end

    if not (love.keyboard.isDown("a") or love.keyboard.isDown("d")) then
        -- friction
        if self.velocity_x > 0 then
            self.velocity_x = self.velocity_x - self.deceleration * dt
            if self.velocity_x < 0 then
                self.velocity_x = 0
            end
        elseif self.velocity_x < 0 then
            self.velocity_x = self.velocity_x + self.deceleration * dt
            if self.velocity_x > 0 then
                self.velocity_x = 0
            end
        end
    end

    self.velocity_x = self.velocity_x + self.acceleration * axis_x * dt

    if self.velocity_x > self.max_speed then
        self.velocity_x = self.max_speed
    elseif self.velocity_x < -self.max_speed then
        self.velocity_x = -self.max_speed
    end
end

function Player:squash(dt)
    if not self.is_ground then
        self.squash_ground_timer = 0.0
        if self.velocity_y > 0 then
            -- 떨어질때
            self.squash_x = lume.lerp(self.squash_x, 1.7, dt * 3)
            self.squash_y = lume.lerp(self.squash_y, 0.6, dt * 1.5)
        elseif self.velocity_y < 0 then
            -- 높아질때
            self.squash_x = lume.lerp(self.squash_x, 0.6, dt * 4)
            self.squash_y = lume.lerp(self.squash_y, 1.2, dt * 7)
        end
    else
        -- 바닥
        self.squash_ground_timer = self.squash_ground_timer + dt
        if self.squash_ground_timer < 0.08 then
            -- 잠시 찌글
            self.squash_x = lume.lerp(self.squash_x, 1.5, dt * 30)
            self.squash_y = lume.lerp(self.squash_y, 0.5, dt * 30)
        else
            -- 회복
            self.squash_x = lume.lerp(self.squash_x, 1.0, dt * 25)
            self.squash_y = lume.lerp(self.squash_y, 1.0, dt * 25)
        end
    end
end

function Player:update_ghosts(dt)
    for i = #self.ghosts, 1, -1 do
        local g = self.ghosts[i]
        g:update(dt)
        if g.should_remove then
            table.remove(self.ghosts, i)
        end
    end
end

function Player:draw_ghosts()
    for i, g in ipairs(self.ghosts) do
        g:draw()
    end
end

function Player:update(dt)
    -- 발끝 위치로 판별

    self:follow_camera(dt)

    if not Gameplay.is_running or Gameplay.clear then
        if not Gameplay.is_running then
            self.x = self.last_spawnpoint_x
            self.y = self.last_spawnpoint_y
            self.squash_x = 1.0
            self.squash_y = 1.0
            self.available_dashes = 1
            self.dash_timer = 0.0
            self.dash_ghost_timer = 0.0
        end
        return
    end

    self.axis_x = 1.0

    tilemap:check_which_level(self.x + self.image:getWidth() / 2, self.y + self.image:getHeight())

    -- 사이에 있는 클립 찾기
    local dt_rem = dt
    local last_chai = 0.0

    for i, action in ipairs(actions_at_stage) do
        if Gameplay.time <= action.t and action.t <= Gameplay.time + dt and not actions_at_stage_state[i] then
            local chai = action.t - Gameplay.time - last_chai
            local act_dt = chai
            dt_rem = dt_rem - chai

            last_chai = last_chai + chai

            print('do: ' .. action.action .. " at " .. tostring(action.t))
            print('act_dt: ' .. tostring(act_dt) .. ' (' .. (chai/dt)*100 .. '% of ' .. tostring(dt) .. '), dt_rem: ' .. tostring(dt_rem))
            self:apply_gravity(act_dt)
            self:move_and_slide(act_dt)
            self:horizontal_move(act_dt)

            if action.action == 'jump' then
                self:handle_jump()
            elseif action.action == 'dash' then
                self:handle_dash()
            end
            actions_at_stage_state[i] = true
        end
    end

    self:apply_gravity(math.max(0.0, dt_rem))
    self:horizontal_move(math.max(0.0, dt_rem))
    self:move_and_slide(math.max(0.0, dt_rem))

    self:footstep(dt)

    self:squash(dt)

    self:update_dash(dt)
    self:update_ghosts(dt)

    if self.is_ground then
        self.available_jumps = 0
    end

    if self.is_ground then
        self.available_dashes = 1
    end

    self.prev_is_ground = self.is_ground
end

function Player:draw()
    self:draw_ghosts()

    love.graphics.setColor(1, 1, 1, 1)

    local off_x = 0.0

    if self.last_direction < 0 then
        off_x = self.image:getWidth()
    end

    love.graphics.draw(self.image,
        self.x - (self.squash_x * self.image:getWidth() - self.image:getWidth()) / 2,
        self.y - (self.squash_y * self.image:getHeight() - self.image:getHeight()),
        0,
        self.last_direction * self.squash_x,
        self.squash_y,

        off_x,
        0.0)
    
    --love.graphics.setColor(1, 0, 0)
    --love.graphics.circle("fill", self.x + 8, self.y + 16, 2)
    --love.graphics.circle("line", self.x, self.y, 2)
    --love.graphics.rectangle("line", self.x, self.y, 16, 16)

    love.graphics.setColor(1, 1, 1, 1)
end

function GhostPlayer:new(x, y, squash_x, squash_y, direction)
    self.x = x
    self.y = y
    self.squash_x = squash_x
    self.squash_y = squash_y
    self.last_direction = direction

    self.alpha = 1.0
    self.should_remove = false
end

function GhostPlayer:update(dt)
    self.alpha = self.alpha - dt * 2.0

    if self.alpha <= 0.0 then
        self.should_remove = true
    end
end

function GhostPlayer:draw()
    love.graphics.setColor(1, 1, 1, self.alpha)

    local off_x = 0.0

    if self.last_direction < 0 then
        off_x = plr.image:getWidth()
    end

    love.graphics.draw(plr.image,
        self.x - (self.squash_x * plr.image:getWidth() - plr.image:getWidth()) / 2,
        self.y - (self.squash_y * plr.image:getHeight() - plr.image:getHeight()),
        0,
        self.last_direction * self.squash_x,
        self.squash_y,

        off_x,
        0.0)

    love.graphics.setColor(1, 1, 1, 1)
end