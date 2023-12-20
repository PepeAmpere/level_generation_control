-- rules of spawning
local minX = MapExt.MIN_X
local minY = MapExt.MIN_Y
local maxX = MapExt.MAX_X
local maxY = MapExt.MAX_Y
local tileSize = MapExt.TILE_SIZE
-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local builders = {
  [1] = function(q, levelMap)
    -- random exit tile in top-left corner
    local exitX = math.random(1,maxX)*900
    local exitY = math.random(minY,-1)*900
    local differentTile = levelMap:GetTile(GetMapTileKey(Vec3(exitX,exitY,0)))
    levelMap:TransformTileToType(differentTile, tileTypesDefs["BP_3x3_exit_door_R_E_M"])
    q.exitTile = differentTile
  end,
  [2] = function(q, levelMap)
    -- select non-structure node
    local function ExitNodeMatcher(node) return node:IsTypeOf("Exit") end
    local _, exitNode = next(q.exitTile:GetNodes(ExitNodeMatcher))

    -- define search rules
    local function NodeMatcher(node) return not node:HasTag(MapExt.MAIN_QUEST_TAG) end -- not visited
    local function EdgeMatcher(edge)
      return not edge:HasTag(MapExt.MAIN_QUEST_TAG) and -- not visited
      not edge:HasTag("sp") -- not structural edge
    end
    local function NodeUpdater(node) node:AddTag(MapExt.MAIN_QUEST_TAG) end
    local function EdgeUpdater(edge) edge:AddTag(MapExt.MAIN_QUEST_TAG) end
    local function EndMatcher(node)
      local selectedPosition = Vec3(-900,900,0)
      return node:GetPosition():Distance(selectedPosition) < MapExt.TILE_SIZE
    end
    local edgesInOut = "in" -- reverse search "against" the direction of the edges

    -- run search from exit node
    local result = exitNode:TagRDFSLook(
      NodeMatcher, NodeUpdater,
      EdgeMatcher, EdgeUpdater, edgesInOut,
      EndMatcher
    )
    levelMap.paths[MapExt.MAIN_QUEST_TAG] = result
  end,
  [3] = function(q, levelMap)
    -- find node entering tile from the east
    local function NodeMatcher(nodeA, nodeB)
      return (nodeA:IsTypeOf("EastEntrance") and nodeB:IsTypeOf("SouthEntrance")) or
      (nodeA:IsTypeOf("SouthEntrance") and nodeB:IsTypeOf("EastEntrance"))
    end
    local ritualRoomTileNode = levelMap.paths[MapExt.MAIN_QUEST_TAG]:FindNodePair(NodeMatcher,1)

    -- find which tile it is
    local function EdgeMatcher(edge) return edge:HasTag("sp") end
    local _, structuralEdge = next(ritualRoomTileNode:GetAllEdges(EdgeMatcher, "in"))
    local ritualRoomTile = structuralEdge:GetNodesFrom()[1]

    -- transform the tile
    levelMap:TransformTileToType(ritualRoomTile, tileTypesDefs["BP_3x3_ritual_room"])
  end,
}

local checkers = {
}

return {
  builders = builders,
  checkers = checkers,
}