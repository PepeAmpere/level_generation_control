-- functions and constants related to map maping which are not methods of the map object
local MIN_X = -3
local MIN_Y = -3
local MAX_X = 3
local MAX_Y = 3
local TILE_SIZE = 900

local MAIN_QUEST_TAG = "exitQuest"

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
local ROTATION_LEFT = {
  north = "west",
  east = "north",
  south = "east",
  west = "south",
}
local ROTATION_RIGHT = {
  north = "east",
  east = "south",
  south = "west",
  west = "north",
}
local DIRECTIONS_TO_TILES_STRICT = {
  NESW = "BP_3x3_base_crossroad",

  NES = "BP_3x3_junction_t_NES_M",
  ESW = "BP_3x3_junction_t_ESW_M",
  NSW = "BP_3x3_junction_t_NSW_M",
  NEW = "BP_3x3_junction_t_NEW_M",

  NS = "BP_3x3_corridor_vertical_M",
  EW = "BP_3x3_corridor_horizontal_M",
  NW = "BP_3x3_turn_NW_M",
  NE = "BP_3x3_turn_NE_M",
  SW = "BP_3x3_turn_SW_M",
  ES = "BP_3x3_turn_ES_M",

  N = "BP_3x3_end_N_M",
  E = "BP_3x3_end_E_M",
  S = "BP_3x3_end_S_M",
  W = "BP_3x3_end_W_M",
}
local DIRECTION_TO_SIDES = {
  north = {
    N = "MrelF", 
    E = "MrelR",
    S = "MrelB",
    W = "MrelL"
  },
  east = {
    N = "MrelL", 
    E = "MrelF",
    S = "MrelR",
    W = "MrelB",
  },
  south = {
    N = "MrelB", 
    E = "MrelL",
    S = "MrelF",
    W = "MrelR",
  },
  west = {
    N = "MrelR", 
    E = "MrelB",
    S = "MrelL",
    W = "MrelF",
  }
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
  MIN_X = MIN_X,
  MIN_Y = MIN_Y,
  MAX_X = MAX_X,
  MAX_Y = MAX_Y,
  TILE_SIZE = TILE_SIZE,

  MAIN_QUEST_TAG = MAIN_QUEST_TAG,

  DIRECTIONS = DIRECTIONS,
  DIRECTION_TAG_MATCHER = DIRECTION_TAG_MATCHER,
  DIRECTION_CONNECTOR_TAG_MATCHER = DIRECTION_CONNECTOR_TAG_MATCHER,
  DIR_TO_VEC3 = DIR_TO_VEC3,
  OPPOSITION_TABLE = OPPOSITION_TABLE,

  HALF_RECT_SIZE = 150,
  HALF_SIZE = 450,

  ROTATION_LEFT = ROTATION_LEFT,
  ROTATION_RIGHT = ROTATION_RIGHT,

  DIRECTION_TO_SIDES = DIRECTION_TO_SIDES,
  DIRECTIONS_TO_TILES_STRICT = DIRECTIONS_TO_TILES_STRICT,

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