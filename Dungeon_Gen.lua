-- Dungeon_Gen.lua

local WIDTH = 21 -- must be odd
local HEIGHT = 11 -- must be odd
local FLOOR_PERCENT = 0.35

math.randomseed(os.time())

-- Initialize grid with walls
local dungeon = {}
for y = 1, HEIGHT do
    dungeon[y] = {}
    for x = 1, WIDTH do
        dungeon[y][x] = "#"
    end
end

-- Start carving from center
local cx, cy = math.floor(WIDTH / 2), math.floor(HEIGHT / 2)
dungeon[cy][cx] = "."

local targetFloors = math.floor(WIDTH * HEIGHT * FLOOR_PERCENT)
local carved = 1

while carved < targetFloors do
    local dir = math.random(4)
    if dir == 1 and cy > 2 then cy = cy - 1 -- up
    elseif dir == 2 and cy < HEIGHT - 1 then cy = cy + 1 -- down
    elseif dir == 3 and cx > 2 then cx = cx - 1 -- left
    elseif dir == 4 and cx < WIDTH - 1 then cx = cx + 1 -- right
    end

    if dungeon[cy][cx] == "#" then
        dungeon[cy][cx] = "."
        carved = carved + 1
    end
end

local function randomfloor()
    while true do
        local x, y = math.random(2, WIDTH - 1), math.random(2, HEIGHT - 1)
        if dungeon[y][x] == "." then return x, y end
    end
end

-- Player start (store coords but don't leave '@' in the map)
local px, py = randomfloor()
dungeon[py][px] = "."

-- Exit gate
local ex, ey = randomfloor()
dungeon[ey][ex] = "T"

-- Monsters
for i = 1, 3 do
    local mx, my = randomfloor()
    dungeon[my][mx] = "B"
end

return {
    map = dungeon,
    startX = px,
    startY = py
}
