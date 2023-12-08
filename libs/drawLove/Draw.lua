local MODULE_NAME = "Draw"
local ASSERT_PREFIX = "[" .. MODULE_NAME .. "] "

-- constants localization
local RENDER_FLIP_Y = MapExt.RENDER_FLIP_Y
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local RECT_SIZE2 = MapExt.HALF_RECT_SIZE
local HALF_SIZE2 = MapExt.HALF_SIZE 

-- functions localization
local FlipCoords2D = MapExt.FlipCoords2D

local function Edge(edge)
  if edge:GetType() == "directional" then
    love.graphics.setLineWidth(4)
    love.graphics.setColor(255,0,255,255)

    local coords = {
      edge:GetNodesFrom()[1]:GetPosition():X(),
      edge:GetNodesFrom()[1]:GetPosition():Y(),
      edge:GetNodesTo()[1]:GetPosition():X(),
      edge:GetNodesTo()[1]:GetPosition():Y(),
    }
    love.graphics.line(FlipCoords2D(coords))
    --love.graphics.line(coords)
  end
end

local function Node(node)
  love.graphics.setColor(0,0,255,255)
  if node:HasTag("tc") then love.graphics.setColor(0,127,255,255) end
  if node:HasTag("is") then love.graphics.setColor(127,0,255,255) end
  if node:HasTag("tile") then love.graphics.setColor(127,127,127,255) end
  love.graphics.rectangle(
    "fill",
    node:GetPosition():X() -25,
    (node:GetPosition():Y() +25)*RENDER_FLIP_Y,
    50, 50
  )
end

local function Path(path, color, width)
  if
    path.IsValid and
    path:IsValid()
  then
    love.graphics.setLineWidth(width or 4)

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
  Edge = Edge,
  Node = Node,
  Path = Path,
}