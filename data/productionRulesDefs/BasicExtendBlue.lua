-- constants & functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

-- = any tile in neighborhood of any tree node or leaf which is not constant
local function Matcher(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations  -- prevent infinite recursion

  return tile:IsTypeOf("Virtual_blue") and
        not tile:HasTag(currentIterationTag)
end

local function Transformer(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations -- prevent infinite recursion

  -- updates
  tile:SetTag(currentIterationTag)
  tile:SetType("Undefined_blue")
  local parentTile = tree:GetParentOf(tile)
  local parentDir = parentTile:GetDirectionOf(tile)
  local tileDir = OPPOSITION_TABLE[parentDir]
  parentTile:SetRestriction(parentDir, 2)
  tile:SetRestriction(tileDir, 2)

  -- create virtual tiles around
  for _, direction in ipairs(DIRECTIONS) do
    local neighborVirtualTilePosition = tile:GetNeighborTilePosition(direction)
    local neighborVirtualTileID = GetMapTileKey(neighborVirtualTilePosition)

    if not tree:HasNodeID(neighborVirtualTileID) then
      local neighborVirtualTile = Tile.newFromNode(
        Node.new(
          neighborVirtualTileID,
          neighborVirtualTilePosition,
          "Virtual_blue",
          {
            tile = true,
            [currentIterationTag] = true,
          }
        ),
        levelMap.tileSize
      )

      tree:AddNode(neighborVirtualTile, tile)
    end
  end
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}