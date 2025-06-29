local MODULE_NAME = "Draw"
local ASSERT_PREFIX = "[" .. MODULE_NAME .. "] "

-- constants localization
local RENDER_FLIP_Y = MapExt.RENDER_FLIP_Y
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local RECT_SIZE2 = MapExt.HALF_RECT_SIZE
local HALF_SIZE2 = MapExt.HALF_SIZE

-- functions localization
local FlipCoords2D = MapExt.FlipCoords2D

-- speedup
local textfields = {}

local function Circle(drawMode, position, width, radius, color)
  love.graphics.setLineWidth(width)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.circle(
    drawMode,
    position:Y(),
    -position:X(),
    radius
  )
end

local function Line(position1, position2, width, color)
  love.graphics.setLineWidth(width)
  love.graphics.setColor(color[1], color[2], color[3], color[4])

  local coords = {
    position1:Y(),
    -position1:X(),
    position2:Y(),
    -position2:X(),
  }
  love.graphics.line(coords)
end

local function Polygon(vertices, color, mode)
  if mode == nil then mode = "fill" end
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.polygon(mode, FlipCoords2D(vertices))
end

local function Text(text, position, color)
  love.graphics.setColor(color[1], color[2], color[3], color[4])
  love.graphics.draw(
    text,
    position:Y(),
    -position:X()
  )
end

local function Edge(edge)

  if edge:GetType() == "directional" then
    local startPosition = edge:GetNodesFrom()[1]:GetPosition()
    local endPosition = edge:GetNodesTo()[1]:GetPosition()
    local dirVector = (endPosition - startPosition):Normalize()
    local arrowVector = dirVector:RotateZFixed(120)

    local color = {0, 0.5, 1, 1}
    if edge:HasTag("sp") then
      color = {0.75, 0.75, 0.75, 0.25}
    end
    Line(
      startPosition,
      endPosition,
      3,
      color
    )

    Line(
      endPosition,
      endPosition + arrowVector*10,
      3,
      color
    )
  end

  if edge:GetType() == "multiedge" then
    local nodesTo = edge:GetNodesTo()
    local vertices = {}
    for i=1, #nodesTo do
      local node = nodesTo[i]
      vertices[#vertices + 1] = node:GetPosition():X()
      vertices[#vertices + 1] = node:GetPosition():Y()
    end

    if #vertices > 4 then
      Polygon(vertices, {0, 0.5, 1, 0.125})
    else
      -- no draw anything now
    end
  end
end

local function Node(node)
  local latestColor = {1, 1, 1, 1}
  Circle(
    "fill",
    node:GetPosition(),
    4,
    24,
    latestColor
  )

  latestColor = {0, 0, 1, 1}
  if node:HasTag("tc") then latestColor = {0, 0.5, 1, 1} end
  if node:HasTag("is") then latestColor = {1, 0, 1, 1}  end
  if node:HasTag("tile") then latestColor = {0.5, 0.5, 0.5, 1} end
  Circle(
    "line",
    node:GetPosition(),
    4,
    25,
    latestColor
  )

  local ABOVE_NODE_Y = -50
  local CENTER_X = 50
  local stringToWrite = tostring(node:GetType())
  if textfields[stringToWrite] then
    Text(
      textfields[stringToWrite],
      node:GetPosition() + Vec3(CENTER_X, ABOVE_NODE_Y, 0),
      latestColor
    )
  else
    local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
    textfields[stringToWrite] = text
  end
end

local function Path(path, color, width)
  if
    path.IsValid and
    path:IsValid()
  then
    love.graphics.setLineWidth(width or 20)

    if color ~= nil then
      love.graphics.setColor(unpack(color))
    else
      love.graphics.setColor(Colors.PATH())
    end

    love.graphics.line(FlipCoords2D(path:GetNodesCoords2D()))
  else
    assert(ASSERT_PREFIX .. "Path is not valid")
  end
end

return {
  Circle = Circle,
  Line = Line,
  Polygon = Polygon,
  Text = Text,
  Edge = Edge,
  Node = Node,
  Path = Path,
}