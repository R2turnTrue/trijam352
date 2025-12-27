Tilemap = Object:extend()

function Tilemap:new(levelIndexLast)
    self.levelFile = LdtkFile("assets/trijam352.ldtk")

    print('level file loaded length: ', #self.levelFile:getLevels())

    self.dragable_tiles = {}
    self.flags = {}

    self.level_bb = {}
    for i, level in ipairs(self.levelFile:getLevels()) do
        table.insert(self.level_bb, {
            x = level.offset_x,
            y = level.offset_y,
            w = level.width,
            h = level.height,
            l = level
        })

        for j, layer in ipairs(level:getLayers()) do
            local entities = layer:getEntities()

            if #entities > 0 then
                self:load_entities(level, entities)
            end
        end
    end

    self.ghostLevel = nil
    self.currentLevel = self.levelFile:getLevels()[levelIndexLast or 1]
    self.levelIndex = levelIndexLast or 1
    --print("init: ", self.currentLevel)
    self.tileset = love.graphics.newImage("assets/sprites/tileset.png")
    self.clear_timer = 0.0
end

function Tilemap:load_entities(level, entities)
    for i, entity in ipairs(entities) do
        if suti.starts(entity.id, "DragTile") then
            --print(entity.id)
            --print("rep")
            local tile_type_id = string.gsub(entity.id, "DragTile_", "")
            --print("'" .. tile_type_id .. "'")
            local drag_tile = DragTile(
                entity.x + level.offset_x,
                entity.y + level.offset_y,
                tonumber(tile_type_id)
            )
            table.insert(self.dragable_tiles, drag_tile)
        end

        if entity.id == "Flag" then
            local flag = Flag(
                entity.x + level.offset_x,
                entity.y + level.offset_y
            )
            table.insert(self.flags, flag)
        end
    end
end

function Tilemap:check_which_level(x, y)
    for i, level_bb in ipairs(self.level_bb) do
        if Physics.checkPointInRect(x, y, level_bb) then
            if self.currentLevel.index ~= level_bb.l.index then
                if self.currentLevel.index then
                    self.ghostLevel =
                        self.level_bb[self.currentLevel.index].l
                end
            end
            self.currentLevel = level_bb.l
            return level_bb.l
        end
    end

    return nil
end

function Tilemap:checkCollision(targetRect, check_drag, check_flag)
    --print("col: ", self.currentLevel)
    for i, layer in ipairs(self.currentLevel:getLayers()) do
        if layer.data.__identifier == "Tiles" then
            local tiles = layer:getTiles()

            for j, tile in ipairs(tiles) do
                local tileRect = {
                    x = tile.x + self.currentLevel.offset_x,
                    y = tile.y + self.currentLevel.offset_y,
                    w = 16,
                    h = 16
                }

                if Physics.checkAABB(targetRect, tileRect) then
                    return tileRect
                end
            end
        end
    end

    if check_drag then
        for i, drag_tile in ipairs(self.dragable_tiles) do
            local drag_tile_rect = drag_tile:getRect()
            if Physics.checkAABB(targetRect, drag_tile_rect) then
                return drag_tile_rect
            end
        end
    end

    if check_flag then
        for i, flag in ipairs(self.flags) do
            local flag_rect = flag:getRect()
            if Physics.checkAABB(targetRect, flag_rect) then
                if not Gameplay.clear then
                    for j = 1, 8 do
                        -- x
                        -- y
                        -- vx
                        -- vy
                        -- lifetime
                        -- radius
                        -- gravity
                        -- col
                        local p = Particle(flag.x + flag_sprite:getWidth() / 2,
                                            flag.y + flag_sprite:getHeight() / 2,
                                            math.random() * 76 - 36,
                                            -50 - math.random() * 25,
                                            1,
                                            3,
                                            70)
                        table.insert(particles, p)
                    end
                end
                Gameplay.clear = true
                return nil
            end
        end
    end

    return nil
end

function Tilemap:drawLevel(level)
    for i, layer in ipairs(level:getLayers()) do
        if layer.data.__identifier == "Tiles" then
            local tiles = layer:getTiles()

            for j, tile in ipairs(tiles) do
                local quad = love.graphics.newQuad(
                    tile.srcX,
                    tile.srcY,
                    16,
                    16,
                    self.tileset:getWidth(),
                    self.tileset:getHeight()
                )

                love.graphics.draw(self.tileset, quad, tile.x + level.offset_x, tile.y + level.offset_y)
            end
        end
    end
end

function Tilemap:update(dt)
    for i, drag_tile in ipairs(self.dragable_tiles) do
        drag_tile:update(dt)
    end

    if Gameplay.clear then
        self.clear_timer = self.clear_timer + dt
        if self.clear_timer >= 0.5 then
            print("reloading")
            self.levelIndex = self.levelIndex + 1
            self.clear_timer = 0.0
            if self.levelIndex > #self.levelFile:getLevels() then
                self.levelIndex = 1
                Gameplay.ended = true
            end
            Gameplay.clear = false
            tilemap.currentLevel = self.levelFile:getLevels()[self.levelIndex]
            plr.x = tilemap.currentLevel.spawn_x
            plr.y = tilemap.currentLevel.spawn_y
            plr.last_spawnpoint_x = plr.x
            plr.last_spawnpoint_y = plr.y
            plr.velocity_x = 0.0
            plr.velocity_y = 0.0
            Gameplay.is_running = false
        end
    else
        self.clear_timer = 0.0
    end
end

function Tilemap:draw()
    if self.ghostLevel then
        self:drawLevel(self.ghostLevel)
    end
    self:drawLevel(self.currentLevel)
    
    for i, drag_tile in ipairs(self.dragable_tiles) do
        drag_tile:draw()
    end

    for i, flag in ipairs(self.flags) do
        flag:draw()
    end
end