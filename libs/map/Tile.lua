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
  i.neighborsPositions = {
    north = i.position + DIR_TO_VEC3.north * tileSize,
    east = i.position + DIR_TO_VEC3.east * tileSize,
    south = i.position + DIR_TO_VEC3.south * tileSize,
    west = i.position + DIR_TO_VEC3.west * tileSize,
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

function Tile:Export()
  local exportedObject = {}

  -- export all keys automatically unless specifically handled
  for k,v in pairs(self) do
    if k == "edgesIn" or k == "edgesOut" then
      exportedObject[k] = {}
      for edgeID, _ in pairs(v) do
        exportedObject[k][edgeID] = true
      end
    elseif k == "neighbors" then
      exportedObject[k] = "Determinstic replication"
    else
      exportedObject[k] = v
    end
  end

  return exportedObject
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

function Tile:GetDirectionOf(neighborTile)
  for direction, neighborPos in pairs(self.neighborsPositions) do
    if GetMapTileKey(neighborPos) == neighborTile:GetID() then
      return direction
    end
  end
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

function Tile:GetNeighborTileID(direction)
  local tilePosition = self.neighborsPositions[direction]
  return GetMapTileKey(tilePosition)
end

function Tile:GetNeighborTilePosition(direction)
  return self.neighborsPositions[direction]
end

function Tile:GetRestriction(direction)
  return self.restrictions[direction]
end

function Tile:GetRestrictions()
  return self.restrictions
end

function Tile:IsMatchingTransformation(tileTypeDef)
  local restrictions = self:GetRestrictions()

  for _, direction in ipairs(DIRECTIONS) do
    local dirRestriction = restrictions[direction]
    local tileDefRestriction = tileTypeDef.restrictions[direction]

    -- check if the tile is not providing exit in restricted direction
    if (dirRestriction == 0) and
      tileDefRestriction ~= 0
    then
      return false
    end

    -- check if the tile is providing exit in the mandatory direction
    if (dirRestriction == 2) and
      tileDefRestriction ~= 2
    then
      return false
    end

    -- now temporarly check if it is not tile def of a unique room
    -- later probably replace by dedicated flag
    if
      tileTypeDef.name == "BP_3x3_exit_door_R_E_M" or
      tileTypeDef.name == "BP_3x3_kitchen" or
      tileTypeDef.name == "BP_3x3_ritual_room"
    then
      return false
    end
  end

--[[
  print(restrictions["north"], restrictions["east"], restrictions["south"], restrictions["west"])
  print(
    tileTypeDef.restrictions["north"],
    tileTypeDef.restrictions["east"],
    tileTypeDef.restrictions["south"],
    tileTypeDef.restrictions["west"]
  )
]]--
  return true
end

function Tile:SetNeighborReference(direction, neighborTile)
  self.neighbors[direction] = neighborTile
end

function Tile:SetRestriction(key, value)
  if key == nil then assert(false, "Tile:SetRestriction, direction is nil") end
  self.restrictions[key] = value
end
function Tile:TransformToType(typeTypeDefinition)
  self:SetType(typeTypeDefinition.name)
end

return Tile