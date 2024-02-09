-- constants & functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

-- = always available
local function AvailabilityPrecodition(levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local tilesCounts = levelMap:ConstructionGetTilesCoutPerType()

  local ratioBlueYellow = tilesCounts["Virtual_yellow"] / tilesCounts["Virtual_yellow"]
  return tilesCounts["Virtual_yellow"] < 30 and
        tilesCounts["Undefined_yellow"] < 40 and
        tilesCounts["BP_3x3_exit_door_R_E_M"] >= 1 and
        (tilesCounts["BP_3x3_ritual_room"] >= 1 and ratioBlueYellow > 0.5) or
        tilesCounts["BP_3x3_ritual_room"] < 1
end

-- = typically the last resort of the growth
-- but at the same the time the most applicable, because of the tolerant precondition
local function UpdateScore(levelMap)
  local newScores = {
    maxDepth = levelMap:ConstructionGetMaxDepth(),
    tilesCountPerType = levelMap:ConstructionGetTilesCoutPerType(),
  }
  levelMap:ConstructionUpdateScores(newScores)
  return levelMap
end

local function SearchAndTransform(Matcher, Transformer, levelMap)
  local constructionTree = levelMap:GetConstructorTree()

  constructionTree:RunSearchAndTransform(Matcher, Transformer, levelMap)
end

-- = any tile in neighborhood of any tree node or leaf which is not constant
local function Matcher(tree, tile, levelMap)
  local scores = levelMap:ConstructionGetScoresCopy()
  local tilePosition = tile:GetPosition()
  local currentIterationTag = "t" .. scores.iterations  -- prevent infinite recursion

  return tile:IsTypeOf("Virtual_yellow") and
        not tile:HasTag(currentIterationTag) and
        tilePosition:Y() > -3500 and
        tilePosition:X() < 3500 and (
          (scores.iterations < 3 and tilePosition:Y() < -0) or
          (scores.iterations >= 3 and
            not (
              tile:HasTag("t0") or
              tile:HasTag("t1")
            )
          )
        )
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
  for _, direction in ipairs(DIRECTIONS) do
    local neighborVirtualTilePosition = tile:GetNeighborTilePosition(direction)
    local neighborVirtualTileID = GetMapTileKey(neighborVirtualTilePosition)

    if not tree:HasNodeID(neighborVirtualTileID) then
      if
        math.random() > 0.3 or
        scores.iterations < 7 or
        direction == parentDir
      then
        local neighborVirtualTile = Tile.newFromNode(
          Node.new(
            neighborVirtualTileID,
            neighborVirtualTilePosition,
            "Virtual_yellow",
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
end

return {
  AvailabilityPrecodition = AvailabilityPrecodition,
  UpdateScore = UpdateScore,
  SearchAndTransform = SearchAndTransform,
  Matcher = Matcher,
  Transformer = Transformer,
}