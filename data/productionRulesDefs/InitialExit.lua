-- constants & functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

-- = any tile in neighborhood of any tree node or leaf which is not constant
local function Matcher(tree, tile, levelMap)
  return tile:IsTypeOf("Undefined")
end

local function Transformer(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations -- prevent infinite recursion

  -- updates
  tile:SetTag(currentIterationTag)
  tile:SetType("BP_3x3_exit_door_R_E_M")

  -- set the restrictions
  for _, direction in ipairs(DIRECTIONS) do
    local tileDef = tileTypesDefs[tile:GetType()]
    local restrictionToSet = tileDef.restrictions[direction]

    -- set it first on yourself
    tile:SetRestriction(direction, restrictionToSet)

    local neighborVirtualTilePosition = tile:GetNeighborTilePosition(direction)
    local neighborVirtualTileID = GetMapTileKey(neighborVirtualTilePosition)

    if tree:HasNodeID(neighborVirtualTileID) then
      local neighborVirtualTile = tree:GetNode(neighborVirtualTileID)
      neighborVirtualTile:SetRestriction(OPPOSITION_TABLE[direction], restrictionToSet)
    end
  end
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}