UI = {}

local play_button_spr = love.graphics.newImage("assets/sprites/play_button.png")
local play_button_spr_sel = love.graphics.newImage("assets/sprites/play_button_sel.png")
local timebar = love.graphics.newImage("assets/sprites/timebar.png")
local jump = love.graphics.newImage("assets/sprites/jump.png")
local dash = love.graphics.newImage("assets/sprites/dash.png")
local direction = love.graphics.newImage("assets/sprites/direction.png")

local stop_button_spr = love.graphics.newImage("assets/sprites/stop_button.png")
local stop_button_spr_sel = love.graphics.newImage("assets/sprites/stop_button_sel.png")

function UI.mousePressed(x, y, button, istouch, presses)
    if button ~= 1 then
        return
    end

    if Gameplay.clear then
        return
    end

    local mouse_x, mouse_y = cam:screen_to_world_no_cam_pos(x, y)

    if
        Physics.checkPointInRect(
            mouse_x,
            mouse_y,
            {
                x = 20,
                y = 155,
                w = play_button_spr:getWidth(),
                h = play_button_spr:getHeight()
            }
        )
     then
        Gameplay.is_running = not Gameplay.is_running
    end
end

function UI.time_to_x(t)
    return math.floor(35 + (250) * (t / max_time))
end

function UI.draw()
    -- draw UI elements here
    UI.drawPlayButton(20, 155)

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.rectangle("fill", 36, 150, 250, 21)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(direction, 28, 137)

    for i, action in ipairs(actions_at_stage) do
        if action.action == 'jump' then
            love.graphics.draw(jump, UI.time_to_x(action.t), 152, 0, 1.0, 1.0, jump:getWidth() / 2, 0)
        elseif action.action == 'dash' then
            love.graphics.draw(dash, UI.time_to_x(action.t), 152, 0, 1.0, 1.0, dash:getWidth() / 2, 0)
        end
    end

    love.graphics.draw(timebar, UI.time_to_x(Gameplay.time), 151, 0, 1, 1, 0.0, 0)
end

function UI.drawPlayButton(x, y)
    local mouse_x, mouse_y = love.mouse.getPosition()
    local mouse_x, mouse_y = cam:screen_to_world_no_cam_pos(mouse_x, mouse_y)

    if
        Physics.checkPointInRect(
            mouse_x,
            mouse_y,
            {
                x = x,
                y = y,
                w = play_button_spr:getWidth(),
                h = play_button_spr:getHeight()
            }
        )
     then

        if Gameplay.is_running then
            love.graphics.draw(stop_button_spr_sel, x, y)
        else
            love.graphics.draw(play_button_spr_sel, x, y)
        end
    else
        if Gameplay.is_running then
            love.graphics.draw(stop_button_spr, x, y)
        else
            love.graphics.draw(play_button_spr, x, y)
        end
    end


end