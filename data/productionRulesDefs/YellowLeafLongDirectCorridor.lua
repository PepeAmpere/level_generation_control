-- constants & functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local DIRECTIONS = MapExt.DIRECTIONS
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE
local LENGTH_MIN = 1
local LENGTH_MAX = 4

-- = any tile in neighborhood of any tree node or leaf which is not constant
local function Matcher(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local tilePosition = tile:GetPosition()
  local currentIterationTag = "t" .. scores.iterations  -- prevent infinite recursion
  local clearance = true
  local tileSize = levelMap.tileSize
  local parentDirection = levelMap:ConstructionGetParentTileDirection(tile)
  if parentDirection then
    for i=1, LENGTH_MAX do
      local nextTilePosition = tilePosition + (DIR_TO_VEC3[parentDirection] * i * tileSize)
      local nextTileID = GetMapTileKey(nextTilePosition)
      if tree:HasNodeID(nextTileID) then
        clearance = false
        break
      end
    end
  else -- root node
    clearance = false
  end

  return tile:IsTypeOf("Virtual_yellow") and
        not tile:HasTag(currentIterationTag) and
        tilePosition:Y() > -3500 and
        tilePosition:X() < 3500 and
        clearance
end

local function Transformer(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations -- prevent infinite recursion

  -- updates
  tile:SetTag(currentIterationTag)
  tile:SetType("Undefined_yellow")
  local parentTile = tree:GetParentOf(tile)
  local parentDir = parentTile:GetDirectionOf(tile)
  local tileDir = OPPOSITION_TABLE[parentDir]
  parentTile:SetRestriction(parentDir, 2)
  tile:SetRestriction(tileDir, 2)

  -- create virtual tiles around
  local direction = parentDir
  local previousTile = tile
  local finalLength = math.random(LENGTH_MIN, LENGTH_MAX)
  local tileType = "Undefined_yellow"
  local tilePosition = tile:GetPosition()
  local tileSize = levelMap.tileSize
  for i=1, finalLength do
    if i == finalLength then tileType = "Virtual_yellow" end
    local nextTilePosition = tilePosition + (DIR_TO_VEC3[direction] * i * tileSize)
    local nextTileID = GetMapTileKey(nextTilePosition)
    local neighborVirtualTile = Tile.newFromNode(
      Node.new(
        nextTileID,
        nextTilePosition,
        tileType,
        {
          tile = true,
          [currentIterationTag] = true,
        }
      ),
      levelMap.tileSize
    )

    tree:AddNode(neighborVirtualTile, previousTile)
    previousTile = neighborVirtualTile
  end
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}