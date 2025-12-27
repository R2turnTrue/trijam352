-- debugger attachment
if arg[2] == "debug" then
    require("lldebugger").start()
end

require("suti")
push = require("lib.push")
push:setupScreen(320, 180, 1280, 720, {
    fullscreen = false,
    resizable = true,
    pixelperfect = true
})

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    tut_spr = love.graphics.newImage("assets/sprites/tut0.png")
    end_spr = love.graphics.newImage("assets/sprites/game_end.png")

    lume = require("lib.lume")
    Object = require("lib.classic")
    require("flag")
    require("gameplay")
    require("drag_tile")
    require("physics")
    require("lib.rdtk")
    require("camera")
    require("tilemap")
    require("player")
    require("particle")
    require("ui")
    
    cam = Camera(0, 0)
    particles = {}
    tilemap = Tilemap()
    plr = Player(tilemap.currentLevel.spawn_x, tilemap.currentLevel.spawn_y)
end

function love.keypressed(key)
    if key == "7" then
        print("reloading")
        local levelIndexLast = tilemap.levelIndex
        tilemap = Tilemap(levelIndexLast)
    end

    if key == "8" then
        Gameplay.clear = true
    end
end

---called in update
---@param dt number
function love.update(dt)
    local dt_clamped = math.min(dt, 0.0333) -- cap delta time to 33.3ms (30fps) to avoid physics issues on slow frames
    dt = dt_clamped
    require("lib.lurker").update()

    if Gameplay.ended then
        return
    end
    
    cam:update(dt)
    
    --
    -- update game
    --
    tilemap:update(dt)
    plr:update(dt)

    for i = #particles, 1, -1 do
        local p = particles[i]
        p:update(dt)
        if p.should_remove then
            table.remove(particles, i)
        end
    end

    Gameplay.update(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
    print('love mousepressed')
    UI.mousePressed(x, y, button, istouch, presses)
    DragTile.mousePressed(x, y, button, istouch, presses)
end

function love.draw()
    push:start()

    if Gameplay.ended then
        love.graphics.clear(0, 0, 0)
        love.graphics.draw(end_spr, 0, 0)
        push:finish()
        return
    end

    cam:start()

    love.graphics.clear(0, 0, 0)

    --
    -- draw game
    --

    tilemap:draw()
    plr:draw()

    for i = #particles, 1, -1 do
        local p = particles[i]
        p:update(love.timer.getDelta())
        p:draw()
        if p.should_remove then
            table.remove(particles, i)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tut_spr, 0, 0)

    cam:finish()

    UI.draw()

    push:finish()
end