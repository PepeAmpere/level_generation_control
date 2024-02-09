-- constants & functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local LENGTH_MAX = 4

-- = any tile in neighborhood of any tree node or leaf which is not constant
local function Matcher(tree, tile, levelMap)
  local parentTile = tree:GetParentOf(tile)
  local southNeighbor = tree:GetNode(tile:GetNeighborTileID("south"))
  local westNeighbor = tree:GetNode(tile:GetNeighborTileID("west"))
  local northNeighbor = tree:GetNode(tile:GetNeighborTileID("north"))
  local eastNeighbor = tree:GetNode(tile:GetNeighborTileID("east"))
  local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

  local westNeighborParent
  if westNeighbor then
      westNeighborParent = tree:GetParentOf(westNeighbor)
  end
  if northNeighbor then
    northNeighborParent = tree:GetParentOf(northNeighbor)
  end
  local clearance = true
  local tileSize = levelMap.tileSize
  local tilePosition = tile:GetPosition()
  local parentDirection = levelMap:ConstructionGetParentTileDirection(tile)
  if parentDirection then
    for i=1, LENGTH_MAX do
      local nextTilePosition = tilePosition + (DIR_TO_VEC3["east"] * i * tileSize)
      local nextTileID = GetMapTileKey(nextTilePosition)
      if tree:HasNodeID(nextTileID) then
        clearance = false
        break
      end
    end
  else -- root node
    clearance = false
  end

  return 
        clearance and
        parentTile ~= nil and
        southNeighbor ~= nil and
        (tile:IsTypeOf("Undefined_yellow") or tile:IsTypeOf("Virtual_yellow"))and
        parentTile:IsEqual(southNeighbor) and
        parentTile:IsTypeOf("Undefined_yellow") and
        (westNeighbor == nil or westNeighbor:GetRestriction("east") ~= 2) and
        (westNeighborParent == nil or not westNeighborParent:IsEqual(tile)) and
        (northNeighbor == nil or northNeighbor:GetRestriction("south") ~= 2) and
        (northNeighborParent == nil or not northNeighborParent:IsEqual(tile)) and
        (eastNeighbor == nil or eastNeighbor:IsTypeOf("Virtual_yellow")) and
        tilesCounts["BP_3x3_ritual_room"] < 1
end

local function Transformer(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations -- prevent infinite recursion

  -- updates
  tile:SetTag(currentIterationTag)
  tile:SetType("BP_3x3_ritual_room")
  local parentTile = tree:GetParentOf(tile)
  local parentDir = parentTile:GetDirectionOf(tile)
  local tileDir = OPPOSITION_TABLE[parentDir]
  parentTile:SetRestriction(parentDir, 2)
  tile:SetRestriction(tileDir, 2)

  -- create virtual tiles around
  local direction = "east"
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
    neighborVirtualTile:SetRestriction("west", 2)
  else
    local eastNeighbor = tree:GetNode(neighborVirtualTileID)
    tree:SetAParentOfB(tile, eastNeighbor)
    eastNeighbor:SetType("Virtual_blue")
    eastNeighbor:SetRestriction("west", 2)
  end
  tile:SetRestriction("east", 2)
end

return {
  Matcher = Matcher,
  Transformer = Transformer,
}