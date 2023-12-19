-- functions related to map maping which are not methods of the map object

local DIRECTIONS = {
  "north",
  "east",
  "south",
  "west"
}
local DIRECTION_TAG_MATCHER = {
  north = function(node) return node:HasTag("north") end,
  east = function(node) return node:HasTag("east") end,
  south = function(node) return node:HasTag("south") end,
  west = function(node) return node:HasTag("west") end
}
local DIRECTION_CONNECTOR_TAG_MATCHER = {
  north = function(node) return node:HasTag("tc") and node:HasTag("north") end,
  east = function(node) return node:HasTag("tc") and node:HasTag("east") end,
  south = function(node) return node:HasTag("tc") and node:HasTag("south") end,
  west = function(node) return node:HasTag("tc") and node:HasTag("west") end
}
local DIR_TO_VEC3 = {
  north = Vec3(1,0,0),
  east = Vec3(0,1,0),
  south = Vec3(-1,0,0),
  west = Vec3(0,-1,0),
}
local OPPOSITION_TABLE = {
  north = "south",
  east = "west",
  south = "north",
  west = "east"
} 

local function CopyPath(path)
  local newPath = {}
  for i = 1, #path do
    newPath[i] = path[i]
  end
  return newPath
end

local function FlipCoords2D(coords)
  local newCoords = {}
  for i=1, #coords do
    if i % 2 == 1 then
      newCoords[i] = coords[i+1]
    else
      newCoords[i] = -coords[i-1]
    end
  end
  return newCoords
end
local function GetDirections()
  return DIRECTIONS
end

local function GetMapTileKey(position)
  return position:X().. "_" .. position:Y()
end

local function GetNodeKey(tileID, nodeName)
  return tileID .. "_" .. nodeName
end

local function GetEdgeKey(uniquePrefix, nodesNames, edgeTags)
  local finalName = uniquePrefix
  for i = 1, #nodesNames do
    finalName = finalName .. "_" .. nodesNames[i]
  end
  for i = 1, #edgeTags do
    finalName = finalName .. "_" .. edgeTags[i]
  end
  return finalName
end

local function GetOppositeDirection(direction)
  return OPPOSITION_TABLE[direction]
end

local function MakePathString(path)
  local pathString = ""
  for i = 1, #path do
    pathString = pathString .. " " .. path[i]
  end

  return pathString
end

local function RandomizeDirection(directionsTable)
  local newDirectionTable = CopyPath(directionsTable)
  for i = #newDirectionTable, 2, -1 do
    local j = math.random(i)
    newDirectionTable[i], newDirectionTable[j] = newDirectionTable[j], newDirectionTable[i]
  end
  return newDirectionTable
end



return {
  DIRECTIONS = DIRECTIONS,
  DIRECTION_TAG_MATCHER = DIRECTION_TAG_MATCHER,
  DIRECTION_CONNECTOR_TAG_MATCHER = DIRECTION_CONNECTOR_TAG_MATCHER,
  DIR_TO_VEC3 = DIR_TO_VEC3,
  HALF_RECT_SIZE = 150,
  HALF_SIZE = 450,
  OPPOSITION_TABLE = OPPOSITION_TABLE,

  CopyPath = CopyPath,
  FlipCoords2D = FlipCoords2D,
  GetDirections = GetDirections,
  GetMapTileKey = GetMapTileKey,
  GetNodeKey = GetNodeKey,
  GetEdgeKey = GetEdgeKey,
  GetOppositeDirection = GetOppositeDirection,
  MakePathString = MakePathString,
  RandomizeDirection = RandomizeDirection,
}