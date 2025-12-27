Gameplay = {
    time = 0.0,
    is_running = false,
    clear = false,
    ended = false
}

actions_at_stage = {}

actions_at_stage_state = {  }

max_time = 5.0

function Gameplay.update(dt)
    if Gameplay.clear then
        return
    end

    if tilemap.levelIndex == 1 then
        actions_at_stage = {
            {
                t = 0.4,
                action = 'jump'
            },
        }
    end
    
    if tilemap.levelIndex == 2 then
        actions_at_stage = {
            {
                t = 0.4,
                action = 'jump'
            },
            {
                t = 1.2,
                action = 'dash'
            },
        }
    end

    if tilemap.levelIndex == 3 then
        actions_at_stage = {
            {
                t = 1.0,
                action = 'jump'
            },
            {
                t = 1.6,
                action = 'jump'
            },

            {
                t = 2.0,
                action = 'jump'
            },

            {
                t = 2.6,
                action = 'jump'
            }
        }
    end

    -- if not size fit, size match actions_at_stage_State
    if #actions_at_stage_state ~= #actions_at_stage then
        actions_at_stage_state = {}
        for i = 1, #actions_at_stage do
            table.insert(actions_at_stage_state, false)
        end
    end
    
    -- OR TOO many, remove
    if #actions_at_stage_state > #actions_at_stage then
        while #actions_at_stage_state > #actions_at_stage do
            table.remove(actions_at_stage_state)
        end
    end

    if Gameplay.is_running then
        Gameplay.time = Gameplay.time + dt

        if Gameplay.time >= max_time then
            Gameplay.time = 0.0
            Gameplay.is_running = false
        end
    else
        Gameplay.time = 0.0
        for i = 1, #actions_at_stage_state do
            actions_at_stage_state[i] = false
        end
    end
end