-- dependency on 
-- * Vec3
-- * Node
-- * MapExt 
-- which is loaded externally to reduce environment specific code

-- constants localization
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local DIRECTIONS = MapExt.DIRECTIONS
local DIRECTION_CONNECTOR_TAG_MATCHER = MapExt.DIRECTION_CONNECTOR_TAG_MATCHER
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE

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
  i.neighborsIDs = {
    north = GetMapTileKey(i.position + DIR_TO_VEC3.north * tileSize),
    east = GetMapTileKey(i.position + DIR_TO_VEC3.east * tileSize),
    south = GetMapTileKey(i.position + DIR_TO_VEC3.south * tileSize),
    west = GetMapTileKey(i.position + DIR_TO_VEC3.west * tileSize),
  }
  i.neighbors = {}
  i.restrictions = {
    north = 1,
    east = 1,
    south = 1,
    west = 1,
  }
  return i
end

function Tile:GetAllNodes()
  local nodes = {}
  for _, edge in pairs(self.edgesOut) do
    local nodeTo = edge:GetNodesTo()[1] -- we know those are just directional edges
    nodes[nodeTo:GetID()] = nodeTo
  end
  return nodes
end

function Tile:GetConnectorPairs()
  local pairsOfConnectors = {}
  for _, direction in ipairs(DIRECTIONS) do
    local neighborTile = self.neighbors[direction]
    if (neighborTile) then
      local oppositeDirection = OPPOSITION_TABLE[direction]
      local myTileMatcher = DIRECTION_CONNECTOR_TAG_MATCHER[direction]
      local neighborTileMatcher = DIRECTION_CONNECTOR_TAG_MATCHER[oppositeDirection]
      local _, myConnectorNode = next(self:GetNodes(myTileMatcher))
      local _, neighborConnectorNode = next(neighborTile:GetNodes(neighborTileMatcher))
      if
        myConnectorNode ~= nil and
        neighborConnectorNode ~= nil
      then
        pairsOfConnectors[direction] = {
          myConnectorNode,
          neighborConnectorNode
        }
      end
    end
  end
  return pairsOfConnectors
end

function Tile:GetNodes(Matcher)
  local selectedNodes = {}
  Matcher = Matcher or function() return true end

  for _, node in pairs(self:GetAllNodes()) do
    if Matcher(node) then
      selectedNodes[node:GetID()] = node
    end
  end
  return selectedNodes
end

function Tile:GetNeighborTile(direction)
  return self.neighbors[direction]
end

function Tile:GetNeighborTileKey(direction)
  return self.neighborsIDs[direction]
end

function Tile:GetRestrictions()
  return self.restrictions
end

function Tile:SetNeighborReference(direction, neighborTile)
  self.neighbors[direction] = neighborTile
end

function Tile:SetRestriction(key, value)
  self.restrictions[key] = value
end
function Tile:TransformToType(typeTypeDefinition)
  self:SetType(typeTypeDefinition.name)
end

return Tile