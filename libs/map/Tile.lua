-- dependency on 
-- * Vec3
-- * Node
-- * MapExt 
-- which is loaded externally to reduce environment specific code

-- constants localization
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3

-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local Tile = {}
Tile.__index = Tile
setmetatable(Tile, Node)

function Tile.newFromNode(node, tileSize)
  local i = setmetatable({}, Tile) -- make new instance
  for k,v in pairs(node) do
    i[k] = v
  end
  i.neighbors = {
    north = GetMapTileKey(i.position + DIR_TO_VEC3.north * tileSize),
    east = GetMapTileKey(i.position + DIR_TO_VEC3.east * tileSize),
    south = GetMapTileKey(i.position + DIR_TO_VEC3.south * tileSize),
    west = GetMapTileKey(i.position + DIR_TO_VEC3.west * tileSize),
  }
  return i
end

function Tile:GetAllNodes()
  local function TypeMatcher(edge) return edge:IsTypeOf("multiedge") end
  local function TagsMatcher(edge) return edge:HasTag("sp")  end
  local tileStructuralEdges = self:GetAllEdges(TypeMatcher, TagsMatcher)

  local tileNodes = {}
  for _, edge in pairs(tileStructuralEdges) do
    for nodeID, node in pairs(edge:GetNodesFrom()) do
      tileNodes[nodeID] = node
    end
    for nodeID, node in pairs(edge:GetNodesTo()) do
      tileNodes[nodeID] = node
    end
  end
  return tileNodes
end

function Tile:GetNeighborTileKey(direction)
  return self.neighbors[direction]
end

function Tile:GetTileRestrictions()
end

function Tile:GetNorth()
  return self.neighbors.north
end

function Tile:TransformToType(typeTypeDefinition)
  self:SetType(typeTypeDefinition.name)
end

return Tile