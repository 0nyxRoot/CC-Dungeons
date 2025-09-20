-- Dungeons.lua

local keyFile = "key.txt"
local GEMINI_KEY = nil

local function loadkey()
    if fs.exists(keyFile) then
        local f = fs.open(keyFile, "r")
        local k = f.readAll()
        f.close()
        if k and #k > 0 then
            return k
        end
    end
    return nil
end

GEMINI_KEY = loadkey()
if not GEMINI_KEY then
    term.clear()
    print("Welcome, adventurer!")
    print("Before you begin, you must provide your Gemini API key.")
    write("Enter API key (or blank to skip AI): ")
    GEMINI_KEY = read("*") or ""
    local f = fs.open(keyFile, "w")
    f.write(GEMINI_KEY)
    f.close()
    print("Key saved! Next time you won't have to enter it.")
    sleep(1.0)
end

local GEMINI_URL = nil
if GEMINI_KEY and GEMINI_KEY ~= "" then
    GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" .. GEMINI_KEY
end

-- Load the dungeon (expects Dungeon_Gen.lua returning map, startX, startY)
local success, dungeonData = pcall(require, "Dungeon_Gen")
if not success or not dungeonData or not dungeonData.map then
    error("Failed to load 'Dungeon_Gen'. Make sure Dungeon_Gen.lua returns the dungeon table.")
end

local dungeon = dungeonData.map
local hero = { x = dungeonData.startX or 1, y = dungeonData.startY or 1 }

-- If the generator put an '@' in the map, clear it (so we don't leave a ghost)
if dungeon[hero.y] and dungeon[hero.y][hero.x] == "@" then
    dungeon[hero.y][hero.x] = "."
end

-- Drawing and AI Helpers
local function drawMap()
    term.clear()
    print("=== Forgotten Catacombs ===")
    for y = 1, #dungeon do
        local row = ""
        for x = 1, #dungeon[y] do
            if x == hero.x and y == hero.y then
                row = row .. "@"
            else
                row = row .. (dungeon[y][x] or "#")
            end
        end
        print(row)
    end
end

local function askGemini(prompt)
    local fallback = "The ancient spirits remain silent..."
    if not GEMINI_URL then return fallback end

    local body = textutils.serializeJSON({
        contents = {{
            parts = {{ text = prompt }}
        }}
    })

    local ok, res = pcall(http.post, GEMINI_URL, body, { ["Content-Type"] = "application/json" })
    if not ok or not res then return fallback end

    local raw = res.readAll()
    res.close()

    local ok2, data = pcall(textutils.unserializeJSON, raw)
    if not ok2 or not data then return fallback end

    if data and data.candidates and data.candidates[1] and data.candidates[1].content and data.candidates[1].content.parts then
        return data.candidates[1].content.parts[1].text or fallback
    end

    return fallback
end

local function narrate(tile)
    local prompt
    if tile == "T" then
        prompt = "Describe a shimmering teleportation gate in a forgotten fantasy dungeon. It should be in a first person perspective, Please also make it sound hopeful but mysterious."
    elseif tile == "B" then
        prompt = "Describe a dangerous beast encounter in a shadowy underground ruin. It should be in a first person perspective. Please also Include a short line of dialogue from the beast."
    else
        prompt = "Describe a dark stone corridor in a high fantasy dungeon. It should be in a first person perspective. Please also Include sights, smells, or faint magical sounds."
    end
    print("\nThe spirits whisper:\n" .. askGemini(prompt))
    sleep(5)
    print("\nPress enter to continue")
    read()
end

-- Movement (with bounds checks)
local function move(dx, dy)
    local nx, ny = hero.x + dx, hero.y + dy
    local width  = #dungeon[1]
    local height = #dungeon
    if nx < 1 or nx > width or ny < 1 or ny > height then
        print("\nYou cannot move further in that direction.")
        return
    end
    local tile = dungeon[ny][nx] or "#"
    if tile ~= "#" then
        hero.x, hero.y = nx, ny
        narrate(tile)
        if tile == "T" then
            print("\nYou step through the Gate and escape the catacombs. Your quest is complete!")
            questActive = false
        end
    else
        print("\nYour path is blocked by unyielding stone.")
    end
end

-- Game loop
local questActive = true

while questActive do
    drawMap()
    print("\nCommands: [W] North, [A] West, [S] South, [D] East, [Q] Quit")
    local key = read()
    if not key then break end
    key = string.lower(key)

    if key == "w" then move(0, -1)
    elseif key == "s" then move(0,  1)
    elseif key == "a" then move(-1, 0)
    elseif key == "d" then move( 1, 0)
    elseif key == "q" then questActive = false
    else print("\nNot a listed command")
    end

    -- small delay so terminal updates cleanly
    sleep(0.05)
end

print("\nYour journey ends here.")
