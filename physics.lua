Physics = {}

function Physics.checkAABB(a, b)
    return a.x <= b.x + b.w and
           a.x + a.w >= b.x and
           a.y <= b.y + b.h and
           a.y + a.h >= b.y
end

function Physics.checkPointInRect(px, py, rect)
    return px >= rect.x and
           px <= rect.x + rect.w and
           py >= rect.y and
           py <= rect.y + rect.h
end