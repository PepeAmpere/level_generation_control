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

function Map:GetTiles()
  local function TagsMatcher(node)
    return node:HasTag("tile")
  end

  return self:GetNodes(nil, TagsMatcher) -- this is table: nodeID => nodeObject
end

function Map:GetTile(tileID)
  return self:GetNode(tileID)
end

function Map:CleanTile(tile)
  -- remove all nodes and edges
  local allTileNodes = tile:GetAllNodes()

  -- removing nodes tables
  for _, tileNode in pairs(allTileNodes) do
    print("    Removing node: " .. tileNode:GetID())
    self:RemoveNode(tileNode)
  end 
  -- remove structural edges on tile node
  tile:RemoveAllEdges()
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
    if edgeDef.nodes then
      local nodesReferences = {}
      for _, nodeType in pairs(edgeDef.nodes) do
        nodeTypes[#nodeTypes + 1] = nodeType
        nodesReferences[#nodesReferences + 1] = nodesTypesInstances[nodeType]
      end
      local newEdgeKey = GetEdgeKey(tile:GetID(), nodeTypes, edgeDef.tags)
      self.edges[newEdgeKey] = Edge.new(
        newEdgeKey,
        {tile},
        nodesReferences,
        edgeDef.edgeType,
        ArrayExt.ConvertToTable(edgeDef.tags)
      )

      for _, node in ipairs(nodesReferences) do
        node:AddEdgeIn(self.edges[newEdgeKey])
        node:AddEdgeOut(self.edges[newEdgeKey])
      end
    else
      nodeTypes[1] = edgeDef.from
      nodeTypes[2] = edgeDef.to

      local newEdgeKey = GetEdgeKey(tile:GetID(), nodeTypes, edgeDef.tags)
      local nodeA = nodesTypesInstances[edgeDef.from]
      local nodeB = nodesTypesInstances[edgeDef.to]
      self.edges[newEdgeKey] = Edge.new(
        newEdgeKey,
        {nodeA}, -- 1 item array
        {nodeB}, -- 1 item array
        edgeDef.edgeType,
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
    local neighborTile =  tile:GetNeighborTile(direction)
    if neighborTile then
      self:ConnectNeighborTiles(neighborTile)
    end
  end
  self:ConnectNeighborTiles(tile)
end

function Map:ConnectNeighborTiles(tile)
  local pairsOfConnectors = tile:GetConnectorPairs()
  for _, direction in ipairs(DIRECTIONS) do
    local directionPair = pairsOfConnectors[direction]
    if directionPair then
      local myConnectorNode, neighborConnectorNode = directionPair[1], directionPair[1]
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

  self:ReestimateTiles()
end

function Map:ReestimateTiles()
  local tiles = self:GetTiles() -- tileID => tile

  for _, tile in pairs(tiles) do
    local pairsOfConnectors = tile:GetConnectorPairs()
    for _, direction in ipairs(DIRECTIONS) do
      local directionPair = pairsOfConnectors[direction]
      if directionPair then
        local myConnectorNode, neighborConnectorNode = directionPair[1], directionPair[2]
        if
          myConnectorNode ~= nil and
          neighborConnectorNode ~= nil
        then
          tile:SetRestriction(direction, 1)
        else
          tile:SetRestriction(direction, 0)
        end
      else
        tile:SetRestriction(direction, 0)
      end
    end
  end
end

return Map