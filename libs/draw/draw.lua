local levelMapExported = require("levelMapExported")

local minX = levelMapExported.minX
local maxX = levelMapExported.maxX
local minY = levelMapExported.minY
local maxY = levelMapExported.maxY

local OFFSET = 50
local TILE_HALF = 24
local Y_FLIP = -1

local CopyPath = MapExt.CopyPath
local GetDirections = MapExt.GetDirections
local function GetMapTileKey(x,y) return MapExt.GetMapTileKey(x, y, minX, maxX, minY, maxY) end
local GetOppositeDirection = MapExt.GetOppositeDirection
local MakePathString = MapExt.MakePathString

local DIRECTIONS = GetDirections()
local DIRECTIONS_LINES = {
  ["north"] = {x = 0, y = 1},
  ["east"] = {x = 1, y = 0},
  ["south"] = {x = 0, y = -1},
  ["west"] = {x = -1, y = 0},
}

local function DrawOnePath(path)
  path = path or {}
  local coords = {}
  for i=1, #path do
    local tileOneX = (levelMapExported.tiles[path[i]].x) * OFFSET
    local tileOneY = (levelMapExported.tiles[path[i]].y) * OFFSET * Y_FLIP
    coords[#coords + 1] = tileOneX
    coords[#coords + 1] = tileOneY
  end
  if #path > 1 then
    love.graphics.setLineWidth(4)
    love.graphics.setColor(0,255,0,128)
    love.graphics.line(unpack(coords))
  end
end

local function DrawProhibitedConnection(coords)
  love.graphics.setLineWidth(4)
  love.graphics.setColor(255,0,0,128)
  love.graphics.line(unpack(coords))
end
  
local function DrawPaths()
  for tileKey, tileData in pairs(levelMapExported.tiles) do
    if tileData.myPath then
      DrawOnePath(tileData.myPath)
    end
  end
end

local function DrawPassLevel()
  for tileKey, tileData in pairs(levelMapExported.tiles) do
    for d = 1, #DIRECTIONS do
      local direction = DIRECTIONS[d]
      if tileData[direction] then
        local x = tileData.x * OFFSET + DIRECTIONS_LINES[direction].x * (TILE_HALF-10)
        local y = (tileData.y * OFFSET + DIRECTIONS_LINES[direction].y * (TILE_HALF-10)) * Y_FLIP
        love.graphics.setColor(32,32,32,255)
        love.graphics.rectangle("fill", x, y, 7, 7)
        love.graphics.setColor(192,192,192,255)
        love.graphics.print(
          tostring(#tileData[direction].passedByPaths), 
          x,
          y,
          0, 0.5, 0.5, 0, 0, 0, 0 ) -- r, sx, sy, ox, oy, kx, ky 
      end
    end
  end
end

local function DrawProhibitedConnections()
  for tileKey, tileData in pairs(levelMapExported.tiles) do
    for d = 1, #DIRECTIONS do
      local direction = DIRECTIONS[d]
      local coords = {}
      if not tileData[direction] then
        DrawProhibitedConnection({
          tileData.x * OFFSET,
          tileData.y * OFFSET * Y_FLIP,
          tileData.x * OFFSET + DIRECTIONS_LINES[direction].x * TILE_HALF,
          tileData.y * OFFSET * Y_FLIP + DIRECTIONS_LINES[direction].y * TILE_HALF * Y_FLIP,
        })
      end
    end
  end
end

local function DrawRooms()
  for i=minX, maxX do
    for j=minY, maxY do
      local tileKey = GetMapTileKey(i,j)
      local tileData = levelMapExported.tiles[tileKey]
      if tileData then
        local x = tileData.x * OFFSET
        local y = tileData.y * OFFSET * Y_FLIP

        local color = roomTypes[tileData.roomType].displayColor
        love.graphics.setColor(unpack(color))
        
        love.graphics.polygon(
          'fill', 
          x-TILE_HALF, y-TILE_HALF, 
          x+TILE_HALF, y-TILE_HALF,
          x+TILE_HALF, y+TILE_HALF,
          x-TILE_HALF, y+TILE_HALF				
        )
      end
    end
  end
end

return {
  DrawRooms = DrawRooms,
  DrawPaths = DrawPaths,
  DrawPassLevel = DrawPassLevel,
  DrawProhibitedConnections = DrawProhibitedConnections
}