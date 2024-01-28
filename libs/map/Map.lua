-- dependency on
-- * ArrayExt
-- * MapExt
-- * Edge
-- * Node
-- * Graph
-- * Tile
-- which is loaded externally to reduce environment specific code

local GetMapTileKey = MapExt.GetMapTileKey
local GetNodeKey = MapExt.GetNodeKey
local GetEdgeKey = MapExt.GetEdgeKey

local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

local Map = {}
Map.__index = Map
setmetatable(Map, Graph)

function Map.new(minX, maxX, minY, maxY, tileSize)
  local i = setmetatable({}, Map) -- make new instance
  minX = minX or -1
  maxX = maxX or 1
  minY = minY or -1
  maxY = maxY or 1
  tileSize = tileSize or 1

  local nodes = {}
  for x = minX*tileSize, maxX*tileSize, tileSize do
    for y = minY*tileSize, maxY*tileSize, tileSize do
      local tileKey = GetMapTileKey(Vec3(x, y, 0))
      local newTile = Tile.newFromNode(
        Node.new(
          tileKey,
          Vec3(x, y, 0),
          nil,
          {
            tile = true
          }
        ),
        tileSize
      )
      nodes[tileKey] = newTile
    end
  end

  i.nodes = nodes
  i.edges = {}
  i.paths = {}

  local allTileNodes = TableExt.ShallowCopy(nodes)

  -- after nodes created, connect them with proper references instead of IDs
  for _, tile in pairs(allTileNodes) do
    for _, direction in ipairs(DIRECTIONS) do
      local neighborTileKey = tile:GetNeighborTileKey(direction)
      if i.nodes[neighborTileKey] then
        tile:SetNeighborReference(direction, i.nodes[neighborTileKey])
      end
    end
  end

  -- set first tile types
  for _, tile in pairs(allTileNodes) do
    i:PopulateTilePerType(tile, tileTypesDefs["Undefined"])
  end

  -- make first connections
  for _, tile in pairs(allTileNodes) do
    i:ConnectNeighborTiles(tile)
  end

  return i
end

function Map:CleanTile(tile)
  -- find all nodes on tile
  local allTileNodes = tile:GetAllNodes()

  -- ? remove all nodes from all graph-like structures attached to map
  -- = paths
  -- = trees
  -- TBD?

  -- removing nodes tables (last existing instances)
  for _, tileNode in pairs(allTileNodes) do
    print("    Removing node: " .. tileNode:GetID())
    self:RemoveNode(tileNode)
  end

  -- remove structural edges on tile node
  tile:RemoveAllEdges()
end

function Map:Cleanup(NodeCleaner, EdgeCleaner)
  for _, node in pairs(self.nodes) do
    NodeCleaner(node)
  end
  for _, edge in pairs(self.edges) do
    EdgeCleaner(edge)
  end
end

function Map:GetTile(tileID)
  return self:GetNode(tileID)
end

function Map:GetTiles()
  local function Matcher(node)
    return node:HasTag("tile")
  end

  return self:GetNodes(Matcher) -- this is table: nodeID => nodeObject
end

function Map:GetUndefinedTiles()
  local function Matcher(node)
    return node:HasTag("tile") and node:IsTypeOf("Undefined")
  end

  return self:GetNodes(Matcher) -- this is table: nodeID => nodeObject
end

function Map:PopulateTilePerType(tile, tileTypeDefinition)
  -- transform tile type itself
  tile:TransformToType(tileTypeDefinition)

  -- add new nodes and edges
  local nodesTypesInstances = {} -- type => node
  for nodeType, nodeDef in pairs(tileTypeDefinition.nodesDefs) do
    local newNodeName = GetNodeKey(tile:GetID(), nodeType)
    local tags = nodeDef.tags or {}
    self.nodes[newNodeName] = Node.new(
      newNodeName,
      tile:GetPosition() + nodeDef.relativePosition,
      nodeType,
      ArrayExt.ConvertToTable(tags)
    )
    nodesTypesInstances[nodeType] = self.nodes[newNodeName]
  end

  for _, edgeDef in pairs(tileTypeDefinition.edgesDefs) do
    local nodeTypes = {}
    local edgeType = edgeDef.edgeType
    if edgeType == "multiedge" then
      local nodesReferences = {}
      for _, nodeType in pairs(edgeDef.nodes) do
        nodeTypes[#nodeTypes + 1] = nodeType
        nodesReferences[#nodesReferences + 1] = nodesTypesInstances[nodeType]
      end
      local newEdgeKey = GetEdgeKey(tile:GetID(), nodeTypes, edgeDef.tags)
      self.edges[newEdgeKey] = Edge.new(
        newEdgeKey,
        nodesReferences,
        nodesReferences,
        edgeType,
        ArrayExt.ConvertToTable(edgeDef.tags)
      )

      for _, node in ipairs(nodesReferences) do
        node:AddEdgeIn(self.edges[newEdgeKey])
        node:AddEdgeOut(self.edges[newEdgeKey])
      end
    end

    if edgeType == "directional" then
      nodeTypes[1] = edgeDef.from
      nodeTypes[2] = edgeDef.to

      local newEdgeKey = GetEdgeKey(tile:GetID(), nodeTypes, edgeDef.tags)
      local nodeA = nodesTypesInstances[edgeDef.from]
      local nodeB = nodesTypesInstances[edgeDef.to]
      self.edges[newEdgeKey] = Edge.new(
        newEdgeKey,
        {nodeA}, -- 1 item array
        {nodeB}, -- 1 item array
        edgeType,
        ArrayExt.ConvertToTable(edgeDef.tags)
      )

      nodeA:Connect(nodeB, self.edges[newEdgeKey])
    end
  end

  local allNodes = {} -- array with objects
  for _, node in pairs(nodesTypesInstances) do
    allNodes[#allNodes + 1] = node

    local structuralTags = {"sp"}
    local newEdgeName = GetEdgeKey(tile:GetID() .. "_" .. node:GetID(), {"OwnedByTile"}, structuralTags)
    self.edges[newEdgeName] = Edge.new(
      newEdgeName,
      {tile}, -- tile node
      {node}, -- given node
      "directional",
      ArrayExt.ConvertToTable(structuralTags)
    )
    tile:Connect(node, self.edges[newEdgeName])
  end
end

function Map:ReconnectTilesAroundTile(tile)
  for _, direction in ipairs(DIRECTIONS) do
    local neighborTile = tile:GetNeighborTile(direction)
    if neighborTile then
      self:ConnectNeighborTiles(neighborTile)
    end
  end
  self:ConnectNeighborTiles(tile)
end

-- central tile is ruling, others mirror the restrictions
function Map:RestrictTilesAroundTile(tile)
--[[
  local neighborDebug = {}
  local neighborID = {}
]]--

  for _, direction in ipairs(DIRECTIONS) do
    local tileDef = tileTypesDefs[tile:GetType()]
    local restrictionToSet = tileDef.restrictions[direction]

    -- set it first on yourself
    tile:SetRestriction(direction, restrictionToSet)

    -- if there is relevant neighbor, set it on it as well
    local neighborTile = tile:GetNeighborTile(direction)
    if neighborTile then
      local oppositeDirection = OPPOSITION_TABLE[direction]
      neighborTile:SetRestriction(oppositeDirection, restrictionToSet)
      --[[
      local neighborTileRestrictions = neighborTile:GetRestrictions()
      neighborDebug[direction] = neighborTileRestrictions[oppositeDirection]
      neighborID[direction] = neighborTile:GetID() 
      ]]--
    end
  end

--[[
  local restrictions = tile:GetRestrictions()
  print("update of " .. tile:GetID() .. " of type " .. tile:GetType())
  print(restrictions.north, restrictions.east, restrictions.south, restrictions.west)
  print(neighborDebug.north, neighborDebug.east, neighborDebug.south, neighborDebug.west)
  print(neighborID.north, neighborID.east, neighborID.south, neighborID.west) 
  ]]--
end

function Map:ConnectNeighborTiles(tile)
  local pairsOfConnectors = tile:GetConnectorPairs()
  for _, direction in ipairs(DIRECTIONS) do
    local directionPair = pairsOfConnectors[direction]
    if directionPair then
      local myConnectorNode, neighborConnectorNode = directionPair[1], directionPair[2]
      if
        myConnectorNode ~= nil and
        neighborConnectorNode ~= nil
      then
        local tags = {"connector"}
        local newEdgeKey = GetEdgeKey(
          tile:GetID(),
          {
            myConnectorNode:GetID(),
            neighborConnectorNode:GetID(),
          },
          tags
        )
        self.edges[newEdgeKey] = Edge.new(
          newEdgeKey,
          {myConnectorNode}, -- 1 item array
          {neighborConnectorNode}, -- 1 item array
          "directional",
          ArrayExt.ConvertToTable(tags)
        )
        myConnectorNode:Connect(neighborConnectorNode, self.edges[newEdgeKey])
      end
    end
  end
end

function Map:TransformTileToType(tile, tileTypeDefinition)
  print("Transforming tile " .. tile:GetID() .. " to " .. tileTypeDefinition.name)

  self:CleanTile(tile)

  self:PopulateTilePerType(tile, tileTypeDefinition)

  self:ReconnectTilesAroundTile(tile)

  self:ReestimateTile(tile)
end

function Map:ReestimateTile(tile)
  -- get nodes in all map paths
  local allNodesOnMapPaths = {}
  for _, path in pairs(self.paths) do
    for nodeID, node in pairs(path:GetNodes()) do
      allNodesOnMapPaths[nodeID] = node
    end
  end

  -- for Undefined tiles, we run this process
  if tile:IsTypeOf("Undefined") then
    local pairsOfConnectors = tile:GetConnectorPairs()
    for _, direction in ipairs(DIRECTIONS) do
      local directionPair = pairsOfConnectors[direction]
      local neighborTile = tile:GetNeighborTile(direction)

      -- check - maybe neighbor is defining it for us already
      if neighborTile == nil or neighborTile:IsTypeOf("Undefined") then
        -- if not, run this process
        if directionPair then
          local myConnectorNode, neighborConnectorNode = directionPair[1], directionPair[2]
          if
            myConnectorNode ~= nil and
            neighborConnectorNode ~= nil
          then
            local myConID = myConnectorNode:GetID()
            local neighborConID = neighborConnectorNode:GetID()
            if allNodesOnMapPaths[myConID]
              and allNodesOnMapPaths[neighborConID]
            then
              tile:SetRestriction(direction, 2) -- = must connect
            else
              tile:SetRestriction(direction, 1) -- = may connect
            end
          else
            tile:SetRestriction(direction, 0) -- = cannot connect
          end
        else
          tile:SetRestriction(direction, 0)
        end
      -- just mirror already decided neighbor setting
      else
        local neighborRestrictions = neighborTile:GetRestrictions()
        tile:SetRestriction(direction, neighborRestrictions[OPPOSITION_TABLE[direction]])
      end
    end

  -- for all other tiles we set it based on tiles defs
  else
    Map:RestrictTilesAroundTile(tile)
  end
end

function Map:ReestimateTiles()
  -- now update all tiles
  local tiles = self:GetTiles() -- tileID => tile
  for _, tile in pairs(tiles) do
    self:ReestimateTile(tile)
  end
end

return Map