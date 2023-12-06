-- functions related to map maping which are not methods of the map object

local DIRECTIONS = {
  "north",
  "east",
  "south",
  "west"
}
local DIR_TO_VEC3 = {
  north = Vec3(0,1,0),
  east = Vec3(1,0,0),
  south = Vec3(0,-1,0),
  west = Vec3(-1,0,0),
}
local RENDER_FLIP_Y = -1
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
  for i=1, #coords do
    if i % 2 == 0 then
      coords[i] = coords[i] * RENDER_FLIP_Y
    end
  end
  return coords
end
local function GetDirections()
  return DIRECTIONS
end

local function GetMapTileKey(position)
  return position:X().. "_" .. position:Y()
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
  DIR_TO_VEC3 = DIR_TO_VEC3,
  HALF_RECT_SIZE = 150,
  HALF_SIZE = 450,
  RENDER_FLIP_Y = RENDER_FLIP_Y,
  OPPOSITION_TABLE = OPPOSITION_TABLE,

  CopyPath = CopyPath,
  FlipCoords2D = FlipCoords2D,
  GetDirections = GetDirections,
  GetMapTileKey = GetMapTileKey,
  GetOppositeDirection = GetOppositeDirection,
  MakePathString = MakePathString,
  RandomizeDirection = RandomizeDirection,
}