-- rules of spawning
local minX = MapExt.MIN_X
local minY = MapExt.MIN_Y
local maxX = MapExt.MAX_X
local maxY = MapExt.MAX_Y
local tileSize = MapExt.TILE_SIZE

-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

-- global for easier Unreal debugging
-- make map
levelMap = Map.new(minX, maxX, minY, maxY, tileSize)

-- generate quests
local quests = {}
for _, questID in ipairs(questTypes) do
  local questDef = questTypesDefs[questID]
  quests[questID] = {}
  quests[questID].questDef = questDef
  if questDef.builders then
    for _, BuilderFunction in ipairs(questDef.builders) do
      local buildResult = BuilderFunction(quests[questID], levelMap)
    end
  end
end

-- !!! example input below

-- start tile
--[[
local startTile = levelMap:GetTile(GetMapTileKey(Vec3(0,0,0)))
levelMap:TransformTileToType(startTile, tileTypesDefs["BP_3x3_ritual_room"])
]]--

-- random kitchen in right top corner
--[[ 
local kitchenX = math.random(1,3)*900
local kitchenY = math.random(1,3)*900
local differentTile = levelMap:GetTile(GetMapTileKey(Vec3(kitchenX,kitchenY,0)))
levelMap:TransformTileToType(differentTile, tileTypesDefs["BP_3x3_kitchen"])
]]--

return levelMap