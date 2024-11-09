
Velocity = {0, 0, 0}
Accel = {0, 0, 0}
PlayerPosition = {0, 0, 0}
Position = {0, 0, 0}

local speed = 60
local friction = 1.04

function Physics_process(delta)
    PlayerPosition[2] = PlayerPosition[2] + 3

    Accel = {
        PlayerPosition[1] - Position[1],
        PlayerPosition[2] - Position[2],
        PlayerPosition[3] - Position[3],
    }

    Accel = mod_loader_normalise(Accel)

    Velocity = {
        (Velocity[1] + Accel[1] * delta * speed) / friction,
        (Velocity[2] + Accel[2] * delta * speed) / friction,
        (Velocity[3] + Accel[3] * delta * speed) / friction,
    }
end
