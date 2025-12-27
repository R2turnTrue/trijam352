DragTile = Object:extend()

drag_tile_sprites = {
    love.graphics.newImage("assets/sprites/drag_tile_1.png")
}

drag_tile_sel_sprites = {
    love.graphics.newImage("assets/sprites/drag_tile_1_sel.png")
}

selected_drag_tile = false
drag_start_x = 0
drag_start_y = 0
drag_ghost_x = 0
drag_ghost_y = 0

last_drag_dir_x = 1
last_drag_dir_y = 1

function DragTile:new(x, y, type)
    self.x = x
    self.y = y
    self.type = type
    self.velocity_x = 0
    self.velocity_y = 0
    self.is_ground = false
    self.image = drag_tile_sprites[self.type]
end

function DragTile:getRect()
    return {
        x = self.x,
        y = self.y,
        w = drag_tile_sprites[self.type]:getWidth(),
        h = drag_tile_sprites[self.type]:getHeight()
    }
end

function DragTile:update(dt)
    if selected_drag_tile == self then
        local mouse_x, mouse_y = love.mouse.getPosition()
        local m_world_x, m_world_y = cam:screen_to_world(mouse_x, mouse_y)

        local dir_x = lume.sign(m_world_x - drag_start_x - drag_ghost_x)
        local dir_y = lume.sign(m_world_y - drag_start_y - drag_ghost_y)
        if dir_x == 0 then
            dir_x = last_drag_dir_x
        end
        if dir_y == 0 then
            dir_y = last_drag_dir_y
        end

        last_drag_dir_x = dir_x
        last_drag_dir_y = dir_y

        drag_ghost_x = 
            self:check_x_axis(lume.lerp(drag_ghost_x, m_world_x - drag_start_x, dt * 10), dir_x, drag_ghost_y)
        drag_ghost_y =
            self:check_y_axis(lume.lerp(drag_ghost_y, m_world_y - drag_start_y, dt * 10), dir_y, drag_ghost_x)
    end

    --self:move_and_slide(dt)

    if not love.mouse.isDown(1) and selected_drag_tile == self then
        selected_drag_tile = nil
        self.x = drag_ghost_x
        self.y = drag_ghost_y
    end
end

function DragTile.mousePressed(x, y, button, istouch, presses)
    if button ~= 1 then
        return
    end

    local mouse_x, mouse_y = cam:screen_to_world(x, y)

    for i, drag_tile in ipairs(tilemap.dragable_tiles) do
        if
            Physics.checkPointInRect(
                mouse_x,
                mouse_y,
                drag_tile:getRect()
            )
         then
            selected_drag_tile = drag_tile
            drag_start_x = mouse_x - drag_tile.x
            drag_start_y = mouse_y - drag_tile.y

            drag_ghost_x = drag_tile.x
            drag_ghost_y = drag_tile.y
            break
        end
    end
end

function DragTile:check_x_axis(new_x, direction_x, new_y)
    local new_bb = self:getRect()
    new_bb.x = new_x
    new_bb.y = new_y or self.y
    local collResult = tilemap:checkCollision(new_bb)

    while collResult do
        if direction_x > 0 then
            -- move right
            new_x = collResult.x - new_bb.w - 0.01
        else
            -- move left
            new_x = collResult.x + collResult.w + 0.01
        end

        new_bb = self:getRect()
        new_bb.x = new_x
        collResult = tilemap:checkCollision(new_bb)
    end

    return new_x
end

function DragTile:check_y_axis(new_y, direction_y, new_x)
    local new_bb = self:getRect()
    new_bb.y = new_y
    new_bb.x = new_x or self.x
    local collResult = tilemap:checkCollision(new_bb)

    while collResult do
        if direction_y > 0 then
            -- move down
            new_y = collResult.y - self.image:getHeight() - 0.0001
        else
            -- move up
            new_y = collResult.y + collResult.h + 0.0001
        end

        new_bb = self:getRect()
        new_bb.y = new_y
        collResult = tilemap:checkCollision(new_bb)
    end

    return new_y
end

function DragTile:draw()
    love.graphics.draw(drag_tile_sprites[self.type], self.x, self.y)

    local mouse_x, mouse_y = love.mouse.getPosition()
    local m_world_x, m_world_y = cam:screen_to_world(mouse_x, mouse_y)

    if Physics.checkPointInRect(m_world_x, m_world_y, self:getRect()) or selected_drag_tile == self then
        love.graphics.draw(
            drag_tile_sel_sprites[self.type],
            self.x,
            self.y
        )
    end

    if selected_drag_tile == self then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(
            drag_tile_sel_sprites[self.type],
            drag_ghost_x,
            drag_ghost_y
        )
        love.graphics.setColor(1, 1, 1, 1)
    end
end