-- CC-Dungeons Downloader

print("Would you like to download CC-Dungeons? (Y/N)")
local answer = read()
answer = string.lower(answer)

if answer == "y" then
  term.clear()
  print("Downloading...")
  wget https://raw.githubusercontent.com/0nyxRoot/CC-Dungeons/refs/heads/main/Dungeons.lua CC-Dungeons.lua
  wget https://raw.githubusercontent.com/0nyxRoot/CC-Dungeons/refs/heads/main/Dungeon_Gen.lua Dungeon_Gen.lua
end

term.clear()
print("Exiting...")
