-- dependency on MapExt which is loaded externally to reduce environment specific code

local mapIndex = {}
local mapMeta = {}
mapMeta.__index = mapIndex
mapMeta.__metatable = false -- access

local CopyPath = MapExt.CopyPath
local GetDirections = MapExt.GetDirections
local GetMapTileKey = MapExt.GetMapTileKey
local GetOppositeDirection = MapExt.GetOppositeDirection

local DIRECTIONS = GetDirections()

local function MakeMeTile(x, z, minX, maxX, minZ, maxZ)
  return {
    x = x,
    z = z,
    alreadyVisited = false,
    roomType = "undefined",
    blocked = false,
    myPath = {},
    north = GetMapTileKey(x, z + 1, minX, maxX, minZ, maxZ),
    east = GetMapTileKey(x + 1, z, minX, maxX, minZ, maxZ),
    south = GetMapTileKey(x, z - 1, minX, maxX, minZ, maxZ),
    west = GetMapTileKey(x - 1, z, minX, maxX, minZ, maxZ),
  }
end

local function new(minX, maxX, minZ, maxZ)
  minX = minX or -1
  maxX = maxX or 1
  minZ = minZ or -1
  maxZ = maxZ or 1
  local tiles = {}
  for x = minX, maxX do
    for z = minZ, maxZ do
      local tileKey = GetMapTileKey(x, z, minX, maxX, minZ, maxZ)
      tiles[tileKey] = MakeMeTile(x, z, minX, maxX, minZ, maxZ)
    end
  end
  return setmetatable(
    {
      minX = minX,
      maxX = maxX,
      minZ = minZ,
      maxZ = maxZ,
      tiles = tiles,
    },
    mapMeta
  ) 
end

local Map = new

function mapIndex:DeleteConnection(tileKey, direction)
  local tiles = self.tiles
  if tiles[tileKey][direction] then
    local tileKeyInDirection = tiles[tileKey][direction]
    tiles[tileKeyInDirection][GetOppositeDirection(direction)] = nil
    tiles[tileKey][direction] = nil
  end
end

function mapIndex:GetTileBlocked(tileKey)
  return self.tiles[tileKey].blocked
end

function mapIndex:GetTileData(tileKey)
  return self.tiles[tileKey]
end

function mapIndex:GetTilePath(tileKey)
  local pathCopy = CopyPath(self.tiles[tileKey].myPath)
  return pathCopy
end

function mapIndex:GetTileRoomType(tileKey)
  return self.tiles[tileKey].roomType
end

function mapIndex:GetTileVisited(tileKey)
  return self.tiles[tileKey].alreadyVisited
end

function mapIndex:SetTileBlocked(tileKey)
  self.tiles[tileKey].blocked = true

  return self
end

function mapIndex:SetTilePath(tileKey, path)
  self.tiles[tileKey].myPath = path  
  return self
end

function mapIndex:SetTileRoomType(tileKey, roomType)
  self.tiles[tileKey].roomType = roomType
  local typeData = roomTypes[roomType]
  for d=1, #DIRECTIONS do
    if typeData.doors[DIRECTIONS[d]] then
    else
      self:DeleteConnection(tileKey, DIRECTIONS[d])
    end
  end
  return self
end

function mapIndex:SetTileVisited(tileKey, visitedValue)
  self.tiles[tileKey].alreadyVisited = visitedValue
  return self
end

return Map