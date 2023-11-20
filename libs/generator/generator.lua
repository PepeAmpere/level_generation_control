-- BFS inspired generator
-- using Mr. Sroubis "water test" method and much more ;)

-- rules of spawning
local minX = -4
local minZ = -4
local maxX = 4
local maxZ = 4
local mapLimits = ((minX - maxX) - 1)  * ((minZ - maxZ) - 1)

-- global for easier Unreal debugging
levelMap = Map(minX, maxX, minZ, maxZ)

-- functions localization
local CopyPath = MapExt.CopyPath
local GetDirections = MapExt.GetDirections
local function GetMapTileKey(x,z) return MapExt.GetMapTileKey(x, z, minX, maxX, minZ, maxZ) end
local GetOppositeDirection = MapExt.GetOppositeDirection
local MakePathString = MapExt.MakePathString
local RandomizeDirection = MapExt.RandomizeDirection
local SaveMapToFile = MapExt.SaveMapToFile

local DIRECTIONS = GetDirections()

math.randomseed(os.time())

-- generation variables
local currentPath = {}
local startTileKey = GetMapTileKey(0, 0)
local currentRoundList = {
  startTileKey
}
local nextRoundlist

-- all paths are starting at the start tile
levelMap:SetTilePath(
  startTileKey, 
  {
      startTileKey
  }
)

-- MANDATORY ROOMS PLACEMENT
-- and related map updates
levelMap:SetTileRoomType(GetMapTileKey(0, 0), "ritualRoom")
levelMap:SetTileVisited(GetMapTileKey(0, 0), true)
local reservedTiles = {
  [GetMapTileKey(0, 0)] = true
}
local mandatoryRooms = {
  "blocked1",
  "blocked2",
  "blocked3",
  "kitchen",
  "officeRoom",
  "exitRoom",
  "restroomMale",
  "restroomFemale",
  "dinnersLeft"
}

for _, roomTypeName in ipairs(mandatoryRooms) do
  local randomX, randomZ, tileKey
  for i=1, 100 do
    randomX = math.floor(math.random(minX+2, maxX-2) / 2) * 2
    randomZ = math.floor(math.random(minZ+2, maxZ-2) / 2) * 2
    tileKey = GetMapTileKey(randomX, randomZ)
    if reservedTiles[tileKey] == nil then
      break
    end
  end 

  if (roomTypeName == "exitRoom") then
    randomX = minX
  end
  if (roomTypeName == "dinnersLeft") then
    levelMap:SetTileRoomType(GetMapTileKey(randomX+1, randomZ), "dinnersRight")
    reservedTiles [GetMapTileKey(randomX+1, randomZ)] = true
  end

  reservedTiles[tileKey] = true
  levelMap:SetTileRoomType(GetMapTileKey(randomX, randomZ), roomTypeName)
end

-- PATHS to all tiles GENERATION
-- under normal circumstances we do up to cycles ()
for i=1, mapLimits do -- maximum is number of tiles (= adding one tile per iteraion)
  
  -- look at neighbours which of tiles in my list
  nextRoundList = {}

  for t=1, #currentRoundList do

    local tileKey = currentRoundList[t]
    -- add all of them which were not visited yet in the nextround list
    local newDirections = RandomizeDirection(DIRECTIONS)
    for d = 1, #newDirections do
      local selectedDirection = newDirections[d]
      local neighbourTileKey = levelMap:GetNeigborTileKey(tileKey, selectedDirection)

      if
        neighbourTileKey and
        not levelMap:GetTileBlocked(neighbourTileKey) and
        not levelMap:GetTileVisited(neighbourTileKey)
      then
        nextRoundList[#nextRoundList + 1] = neighbourTileKey
        levelMap:SetTileVisited(neighbourTileKey, true)
        
        local myNewPath = CopyPath(levelMap:GetTilePath(tileKey))
        myNewPath[#myNewPath + 1] = neighbourTileKey
        levelMap:SetTilePath(neighbourTileKey, myNewPath)
      end
    end
  end

  currentRoundList = {}

  if #nextRoundList > 0 then
    for n=1, #nextRoundList do
      currentRoundList[n] = nextRoundList[n]
    end
  else
    break
  end
end

-- calculate intensity of each path per-tile and per-direction
levelMap:TrackAllPathsPasses()

return levelMap