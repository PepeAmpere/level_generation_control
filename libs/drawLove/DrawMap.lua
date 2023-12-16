-- dependency on 
-- * Vec3
-- * Node
-- * Path
-- * Draw
-- which is loaded externally to reduce environment specific code

-- Calls love 2D specific drawing using custom data structures
-- love 2D specific drawing not related to custom data is in Draw lib

-- constants localization
local RENDER_FLIP_Y = MapExt.RENDER_FLIP_Y
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local RECT_SIZE2 = MapExt.HALF_RECT_SIZE
local HALF_SIZE2 = MapExt.HALF_SIZE 
-- local constants
local ZOOM_SCALE_FACTOR = 0.05
local TILE_KEY_TO_COLOR = {
  w = {234, 234, 234, 255},
  x = {168, 168, 168, 255},
}
local SUBTILES_POSITIONS = {
  Vec3(2*RECT_SIZE2, -2*RECT_SIZE2, 0),  Vec3(2*RECT_SIZE2, 0, 0), Vec3(2*RECT_SIZE2, 2*RECT_SIZE2, 0),
  Vec3(0, -2*RECT_SIZE2, 0),  Vec3(0, 0, 0), Vec3(0, 2*RECT_SIZE2, 0),
  Vec3(-2*RECT_SIZE2, -2*RECT_SIZE2, 0),  Vec3(-2*RECT_SIZE2, 0, 0), Vec3(-2*RECT_SIZE2, 2*RECT_SIZE2, 0),
}

-- functions localization
-- local GetMapTileKey = MapExt.GetMapTileKey

-- testing data
local testingNodes = {}
for i = 1, 5 do
  testingNodes[i] = Node.new(
    "ID" .. i,
    Vec3(
      math.random(-1000, 1000),
      math.random(-1000, 1000),
      0
    )
  )
end
local testingPath = Path.new(testingNodes)
-- speedup
local textfields = {}

local function DrawTile(tile)
  local tileType = tile:GetType()
  local tilePosition = tile:GetPosition()

  local drawData = tileTypesDefs[tileType].drawDefs
  for i=1, #drawData do
    local rectanglePosition = tilePosition + SUBTILES_POSITIONS[i]
    local color = TILE_KEY_TO_COLOR[drawData[i]]
    love.graphics.setColor(unpack(color))
    love.graphics.rectangle(
      "fill",
      (rectanglePosition:Y() - RECT_SIZE2), 
      -rectanglePosition:X() - RECT_SIZE2,
      2*RECT_SIZE2, 2*RECT_SIZE2
    )
    love.graphics.setColor(255,0,255,255)
    local stringToWrite = tostring(rectanglePosition)
    if textfields[stringToWrite] then
      love.graphics.draw(
        textfields[stringToWrite], 
        rectanglePosition:Y(), 
        -rectanglePosition:X()
      )
    else
      local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
      textfields[stringToWrite] = text
    end
  end

  local TILE_SPACING = 10
  love.graphics.setColor(0,0,0,255)
  love.graphics.rectangle(
    "line",
    (tilePosition:Y() - 3*RECT_SIZE2),
    -tilePosition:X() - 3*RECT_SIZE2, 
    6*RECT_SIZE2-TILE_SPACING, 6*RECT_SIZE2-TILE_SPACING
  )
end

local function AllEdges()
  for _, edge in pairs(levelMap.edges) do
    Draw.Edge(edge)
  end
end

local function AllNodes()
  for _, node in pairs(levelMap.nodes) do
    Draw.Node(node)
  end
end

local function AllPaths()
  Draw.Path(testingPath)
end

local function AllTiles()
  local tiles = levelMap:GetTiles()
  for _, tile in pairs(tiles) do
    DrawTile(tile)
  end
end

local function CameraAndCursorPosition(camera)
  local cx, cy = camera:getPosition()
  local mx, my = love.mouse.getPosition()
  local _, _, cw, ch = camera:getVisible()
  local mw, mh, flags = love.window.getMode()
  local mWx, mWy = camera:toWorld(mx,my)
  local visbleCornerX, visibleCornerY = camera:getVisibleCorners()
  love.graphics.setColor(255,0,255,255)
  love.graphics.print("cx: " .. math.floor(cx) .. " cy: " .. math.floor(cy), 10, 10)
  love.graphics.print("cw: " .. math.floor(cw) .. " ch: " .. math.floor(ch), 10, 20)
  love.graphics.print("mx: " .. math.floor(mx) .. " my: " .. math.floor(my), 10, 30)
  love.graphics.print("mw: " .. math.floor(mw) .. " mh: " .. math.floor(mh), 10, 40)
  love.graphics.print("mWx: " .. math.floor(mWx) .. " mWy: " .. math.floor(mWy), 10, 50)
  love.graphics.print("visbleCornerX: " .. math.floor(visbleCornerX) .. " visibleCornerY: " .. math.floor(visibleCornerY), 10, 60)
  love.graphics.print("scale: " .. tostring(camera:getScale()), 10, 70)
end

local function DebugControl(camera)
  love.graphics.setColor(255,0,255,255)
  love.graphics.print("Move around:", 10, 440) love.graphics.print("[Up] [Down] [Left] [Right]", 100, 440)
  love.graphics.print("Zoom:", 10, 450) love.graphics.print("[Num+] [Num-]", 100, 450)
  love.graphics.print("Reset to [0,0]:", 10, 460) love.graphics.print("[Space]", 100, 460)
end

local function WheelZoom(camera, x, y)
  local cx, cy = camera:getPosition()
  local mx, my = love.mouse.getPosition()
  local mWx, mWy = camera:toWorld(mx,my)

  if y > 0 then
    camera:setScale(camera:getScale() + ZOOM_SCALE_FACTOR)
  elseif y < 0 then
    camera:setScale(camera:getScale() - ZOOM_SCALE_FACTOR)
  end
  camera:setPosition(
    cx + (mWx - cx)*ZOOM_SCALE_FACTOR,
    cy + (mWy - cy)*ZOOM_SCALE_FACTOR
  )
end

local function ControlKeys(camera, key, scancode)
  local cx, cy = camera:getPosition()
  local scale = camera:getScale()
  local scaleInverted = 1/scale
  local delta = RECT_SIZE2 * scaleInverted
  local y = 0

  if key == "left" then cx = cx - delta end
  if key == "right" then cx = cx + delta end
  if key == "up" then cy = cy - delta end
  if key == "down" then cy = cy + delta end
  if key == "kp-" then y = -1 end
  if key == "kp+" then y = 1 end
  if key == "space" then camera:setPosition(0, 0) return end

  if y == 0 then
    camera:setPosition(cx, cy)
  else
    local mx, my = love.mouse.getPosition()
    local mWx, mWy = camera:toWorld(mx,my)
    if y > 0 then
      camera:setScale(camera:getScale() + ZOOM_SCALE_FACTOR)
    elseif y < 0 then
      camera:setScale(camera:getScale() - ZOOM_SCALE_FACTOR)
    end
    camera:setPosition(
      cx + (mWx - cx)*ZOOM_SCALE_FACTOR,
      cy + (mWy - cy)*ZOOM_SCALE_FACTOR
    )
  end
end

local function PanMouse(camera, x, y, dx, dy, istouch)
  local cx, cy = camera:getPosition()
  local mx, my = love.mouse.getPosition()
  local mWx, mWy = camera:toWorld(mx,my)
  local SCALE_FACTOR = 0.05
  
  camera:setPosition(cx - dx, cy - dy)
--[[   camera:setPosition(
    cx + (mWx - cx)*SCALE_FACTOR,
    cy + (mWy - cy)*SCALE_FACTOR
  ) ]]--
end

return {
  AllEdges = AllEdges,
  AllNodes = AllNodes,
  AllPaths = AllPaths,
  AllTiles = AllTiles,
  CameraAndCursorPosition = CameraAndCursorPosition,
  ControlKeys = ControlKeys,
  DebugControl = DebugControl,
  PanMouse = PanMouse,
  WheelZoom = WheelZoom,
}