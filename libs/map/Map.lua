-- dependency on 
-- * MapExt
-- * Edge
-- * Node
-- * Graph
-- * Tile
-- which is loaded externally to reduce environment specific code

local GetMapTileKey = MapExt.GetMapTileKey

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
      local newTile = Tile.newFromNode(Node.new(tileKey, Vec3(x, y, 0)), tileSize)
      newTile:SetTag("tile")
      nodes[tileKey] = newTile
    end
  end

  i.nodes = nodes
  i.edges = {}

  for _, node in pairs(nodes) do
    i:TransformTileToType(node, tileTypesDefs["Undefined"])
  end
  return i
end

function Map:GetTiles()
  local nodes = self:GetNodes()
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
  local tileID = tile:GetID()

  local function TypeMatcher(edge) return edge:IsTypeOf("multiedge") end
  local function TagsMatcher(edge) return edge:HasTag("sp")  end
  local tileStructuralEdges = tile:GetAllEdges(TypeMatcher, TagsMatcher)

  for edgeID,_  in pairs(tileStructuralEdges) do
    self:RemoveEdge(self.edges[edgeID])
  end
  
  -- transform tile iself
  tile:TransformToType(tileTypeDefinition)

  -- transform map
end

return Map