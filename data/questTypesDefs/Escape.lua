-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local builders = {
  [1] = function(q, levelMap)
    -- random exit tile in top-left corner
    local exitX = math.random(1, MapExt.MAX_X)*900
    local exitY = math.random(MapExt.MIN_Y,-1)*900
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
    local function NodeUpdater(node) node:SetTag(MapExt.MAIN_QUEST_TAG) end
    local function EdgeUpdater(edge) edge:SetTag(MapExt.MAIN_QUEST_TAG) end
    local function EndMatcher(node)
      local selectedPosition = Vec3(-900,900,0)
      return node:GetPosition():Distance(selectedPosition) < MapExt.TILE_SIZE
    end
    local edgesInOut = "in" -- reverse search "against" the direction of the edges

    -- run search from exit node
    local resultPath = exitNode:TagRDFSLook(
      NodeMatcher, NodeUpdater,
      EdgeMatcher, EdgeUpdater, edgesInOut,
      EndMatcher
    )
    levelMap.paths[MapExt.MAIN_QUEST_TAG] = resultPath

    -- clean up the nodes and edges
    local function NodeCleaner(node) node:RemoveTag(MapExt.MAIN_QUEST_TAG) end
    local function EdgeCleaner(edge) edge:RemoveTag(MapExt.MAIN_QUEST_TAG) end
    levelMap:Cleanup(NodeCleaner, EdgeCleaner)

    -- update connections
    levelMap:ReestimateTiles()

    -- find node entering tile from the east
    local function NodeMatcher(nodeA, nodeB)
      return (nodeA:IsTypeOf("EastEntrance") and nodeB:IsTypeOf("SouthEntrance")) or
      (nodeA:IsTypeOf("SouthEntrance") and nodeB:IsTypeOf("EastEntrance"))
    end
    local ritualRoomTileNode = resultPath:FindNodePair(NodeMatcher,1)

    if ritualRoomTileNode == nil then
      print("No ritual room tile found = this is almost mathematically impossible if exit is on top and we search for a bottom right tile => probably you changed the setup or introduced the bug")
      -- fallback
      ritualRoomTileNode = resultPath:GetStartNode()
    end

    -- find which tile it is
    local function EdgeMatcher(edge) return edge:HasTag("sp") end
    local _, structuralEdge = next(ritualRoomTileNode:GetAllEdges(EdgeMatcher, "in"))
    local ritualRoomTile = structuralEdge:GetNodesFrom()[1]

    -- transform the tile
    levelMap:TransformTileToType(ritualRoomTile, tileTypesDefs["BP_3x3_ritual_room"])
  end,
}

local checkers = {
  [1] = function(q, levelMap)
  end,
}

return {
  builders = builders,
  checkers = checkers,
}