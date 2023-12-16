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
  local nodes = {}
  for _, edge in pairs(self.edgesOut) do
    local nodeTo = edge:GetNodesTo()[1]
    nodes[nodeTo:GetID()] = nodeTo
  end
  return nodes
end

function Tile:GetNodes(TypeMatcher, TagsMatcher)
  local selectedNodes = {}
  TypeMatcher = TypeMatcher or function() return true end
  TagsMatcher = TagsMatcher or function() return true end

  for _, node in pairs(self:GetAllNodes()) do
    if TypeMatcher(node) and TagsMatcher(node) then
      selectedNodes[node:GetID()] = node
    end
  end
  return selectedNodes
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