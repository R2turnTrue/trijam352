-- debugger attachment
if arg[2] == "debug" then
    require("lldebugger").start()
end

push = require("lib.push")
push:setupScreen(384, 216, 1280, 720, {
    fullscreen = false,
    resizable = true,
    pixelperfect = true
})

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Object = require("lib.classic")
    require("lib.rdtk")
    require("camera")

    cam = Camera(0, 0)
    particles = {}
end

---called in update
---@param dt number
function love.update(dt)
    require("lib.lurker").update()
    
    --
    -- update game
    --
end

function love.draw()
    push:start()
    cam:start()

    love.graphics.clear(1, 1, 1)

    --
    -- draw game
    --

    for i = #particles, 1, -1 do
        local p = particles[i]
        p:update(love.timer.getDelta())
        p:draw()
        if p.should_remove then
            table.remove(particles, i)
        end
    end

    cam:finish()
    push:finish()
end