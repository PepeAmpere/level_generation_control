-- dependency on 
-- * Vec3
-- * Node
-- * Path
-- * Draw
-- which is loaded externally to reduce environment specific code

-- Calls love 2D specific drawing using custom data structures
-- love 2D specific drawing not related to custom data is in Draw lib

-- constants localization
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local DIRECTIONS = MapExt.DIRECTIONS
local RECT_SIZE2 = MapExt.HALF_RECT_SIZE
local HALF_SIZE2 = MapExt.HALF_SIZE

-- local constants
local ZOOM_SCALE_FACTOR = 0.03
local ROTATE_SCALE_FACTOR = 0.05
local TILE_KEY_TO_COLOR = {
  a = {0.8, 0.9, 0.8, 1},
  w = {0.9, 0.9, 0.9, 1},
  x = {0.625, 0.625, 0.625, 1},
  yellow = {0.625, 0.625, 0, 0.5},
  blue = {0, 0, 1, 0.5},
  red = {1, 0, 0, 0.5},
  green = {0, 1, 0, 0.5},
}
local SUBTILES_POSITIONS = {
  Vec3(2*RECT_SIZE2, -2*RECT_SIZE2, 0),  Vec3(2*RECT_SIZE2, 0, 0), Vec3(2*RECT_SIZE2, 2*RECT_SIZE2, 0),
  Vec3(0, -2*RECT_SIZE2, 0),  Vec3(0, 0, 0), Vec3(0, 2*RECT_SIZE2, 0),
  Vec3(-2*RECT_SIZE2, -2*RECT_SIZE2, 0),  Vec3(-2*RECT_SIZE2, 0, 0), Vec3(-2*RECT_SIZE2, 2*RECT_SIZE2, 0),
}

-- functions localization
-- local GetMapTileKey = MapExt.GetMapTileKey
local DrawText = Draw.Text

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

  -- color override per tags
  local replacementColor
  local specialColors = {"blue", "green", "red", "yellow"}
  for _, color in pairs(specialColors) do
    if tile:HasTag(color) then
      replacementColor = TILE_KEY_TO_COLOR[color]
    end
  end

  for i=1, #drawData do

    -- SECTION TO REFACTOR using Draw START
    local rectanglePosition = tilePosition + SUBTILES_POSITIONS[i]
    local symbol = drawData[i]
    local color = TILE_KEY_TO_COLOR[symbol]
    if symbol == "x" then color = replacementColor or TILE_KEY_TO_COLOR[symbol]  end

    love.graphics.setColor(unpack(color))
    love.graphics.rectangle(
      "fill",
      (rectanglePosition:Y() - RECT_SIZE2),
      -rectanglePosition:X() - RECT_SIZE2,
      2*RECT_SIZE2, 2*RECT_SIZE2
    )
    -- SECTION TO REFACTOR END

    local stringToWrite = tostring(rectanglePosition)
    if textfields[stringToWrite] then
      DrawText(textfields[stringToWrite], rectanglePosition, {1,0,1,1})
    else
      local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
      textfields[stringToWrite] = text
    end
  end

  -- SECTION TO REFACTOR using Draw START
  local TILE_SPACING = 10
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle(
    "line",
    (tilePosition:Y() - 3*RECT_SIZE2),
    -tilePosition:X() - 3*RECT_SIZE2, 
    6*RECT_SIZE2-TILE_SPACING, 6*RECT_SIZE2-TILE_SPACING
  )
  -- SECTION TO REFACTOR END
end

local tagsTextfields = {}

local function DrawTileTags(tile)
  local tags = tile:GetTags()
  local index = 0
  for tag, _ in pairs(tags) do
    if tagsTextfields[tag] then
      -- DrawText(tagsTextfields[tag], tile:GetPosition(), {255,0,255,255})
      local drawPosition = tile:GetPosition() + Vec3(index*-100,0,0)
      love.graphics.printf( 
        tag, 
        drawPosition:Y(),
        -drawPosition:X(),
        1000, "left", 0, 10, 10)

      index = index + 1
    else
      local font = love.graphics.getFont()
      local text = love.graphics.newText(font, tag)
      tagsTextfields[tag] = text
    end
  end
end

-- restictions debug
local function DrawTileRestrictions(tile)

  local tileRestrictions = tile:GetRestrictions()
  local tilePosition = tile:GetPosition()

  love.graphics.setColor(1,1,1,0.25)
  for _, direction in ipairs(DIRECTIONS) do
    local sideVector = tilePosition + DIR_TO_VEC3[direction]*2.8*RECT_SIZE2

    local restrictionToImageMap = {
      [2] = images.plus,
      [1] = images.check,
      [0] = images.cross,
    }

    love.graphics.draw(
      restrictionToImageMap[tileRestrictions[direction]],
      sideVector:Y()-32, 
      -sideVector:X()-32
    )
  end
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
  for _, path in pairs(levelMap.paths) do
    Draw.Path(path)
  end
end

local function AllTiles()
  local tiles = levelMap:GetTiles()
  for _, tile in pairs(tiles) do
    DrawTile(tile)
  end
end

local function AllTileRestrictions()
  local tiles = levelMap:GetTiles()
  for _, tile in pairs(tiles) do
    DrawTileRestrictions(tile)
  end
end

local function AllTreeLines()
  local constructorTree = levelMap:GetConstructorTree()
  local rootNode = constructorTree:GetRootNode()
  local rootNodeID = rootNode:GetID()

  local function RecLookup(tree, nodeID)
    local childrenOfNode = tree:GetNodeChildren(nodeID) or {}
    for i=1, #childrenOfNode do
      Draw.Line(
        tree:GetNode(nodeID):GetPosition(),
        tree:GetNode(childrenOfNode[i]):GetPosition(),
        10,
        {0,0.5,0,0.5}
      )
      RecLookup(tree, childrenOfNode[i])
    end
  end

  RecLookup(constructorTree, rootNodeID)
end

local function AllTreeTiles()
  local constructorTree = levelMap:GetConstructorTree()
  local tiles = constructorTree:GetNodes()
  for _, tile in pairs(tiles) do
    DrawTile(tile)
    DrawTileTags(tile)
  end
end

local function CameraAndCursorPosition(camera)
  local cx, cy = camera:getPosition()
  local mx, my = love.mouse.getPosition()
  local _, _, cw, ch = camera:getVisible()
  local mw, mh, flags = love.window.getMode()
  local mWx, mWy = camera:toWorld(mx,my)
  local visbleCornerX, visibleCornerY = camera:getVisibleCorners()
  love.graphics.setColor(1,0,1,1)
  love.graphics.print("cx: " .. math.floor(cx) .. " cy: " .. math.floor(cy), 10, 10)
  love.graphics.print("cw: " .. math.floor(cw) .. " ch: " .. math.floor(ch), 10, 20)
  love.graphics.print("mx: " .. math.floor(mx) .. " my: " .. math.floor(my), 10, 30)
  love.graphics.print("mw: " .. math.floor(mw) .. " mh: " .. math.floor(mh), 10, 40)
  love.graphics.print("mapX: " .. math.floor(-mWy) .. " mapY: " .. math.floor(mWx), 10, 50)
  love.graphics.print("visbleCornerX: " .. math.floor(-visibleCornerY) .. " visibleCornerY: " .. math.floor(visbleCornerX), 10, 60)
  love.graphics.print("scale: " .. tostring(camera:getScale()), 10, 70)
end

local function DebugControl(camera)
  love.graphics.setColor(1,0,1,1)
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

local function PadRotate(camera, x, y)
  camera:setAngle(camera:getAngle() + x * ROTATE_SCALE_FACTOR)
end

local function PadZoom(camera, x, y)
  camera:setScale(camera:getScale() + y * ZOOM_SCALE_FACTOR)
end

local function ControlKeys(camera, key, scancode)
  local cx, cy = camera:getPosition()
  local scale = camera:getScale()
  local scaleInverted = 1/scale
  local delta = RECT_SIZE2/10 * scaleInverted
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
  AllTileRestrictions = AllTileRestrictions,
  AllTreeLines = AllTreeLines,
  AllTreeTiles = AllTreeTiles,
  CameraAndCursorPosition = CameraAndCursorPosition,
  ControlKeys = ControlKeys,
  DebugControl = DebugControl,
  PadRotate = PadRotate,
  PadZoom = PadZoom,
  PanMouse = PanMouse,
  WheelZoom = WheelZoom,
}