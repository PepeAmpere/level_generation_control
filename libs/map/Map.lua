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
  for _, tile in pairs(allTileNodes) do
    i:TransformTileToType(tile, tileTypesDefs["Undefined"])
  end
  return i
end

function Map:GetTiles()
  local nodes = self.nodes
  local filtered = {}
  for nodeID, node in pairs(nodes) do
    if node:HasTag("tile") then
      filtered[nodeID] = node
    end
  end

  return filtered -- this is table: nodeID => nodeObject
end

function Map:GetTile(tileID)
  return self:GetNode(tileID)
end

function Map:TransformTileToType(tile, tileTypeDefinition)
  -- print("Transforming tile " .. tile.id .. " to " .. tileTypeDefinition.name)

  -- remove all nodes and edges
  local allTileNodes = tile:GetAllNodes()

  for _, tileNode in pairs(allTileNodes) do
    self:RemoveNode(tileNode)
  end

  -- transform tile type itself
  tile:TransformToType(tileTypeDefinition)

  -- add new nodes and edges
  local nodesTypesInstances = {}
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
      local nodesRefereces = {}
      for _, nodeType in pairs(edgeDef.nodes) do
        nodeTypes[#nodeTypes + 1] = nodeType
        nodesRefereces[nodeType] = nodesTypesInstances[nodeType]
      end
      local newEdgeName = GetEdgeKey(nodeTypes, edgeDef.tags)
      self.edges[newEdgeName] = Edge.new(
        newEdgeName,
        nodesRefereces,
        nodesRefereces,
        edgeDef.edgeType,
        ArrayExt.ConvertToTable(edgeDef.tags)
      )
    else
      nodeTypes[1] = edgeDef.from
      nodeTypes[2] = edgeDef.to

      local newEdgeName = GetEdgeKey(nodeTypes, edgeDef.tags)
      self.edges[newEdgeName] = Edge.new(
        newEdgeName,
        {nodesTypesInstances[edgeDef.from]}, -- 1 item array
        {nodesTypesInstances[edgeDef.to]}, -- 1 item array
        edgeDef.edgeType,
        ArrayExt.ConvertToTable(edgeDef.tags)
      )
    end
  end

--[[
  for k,v in pairs (self.edges) do
    print(k,v)
  end
  ]]--
end

return Map