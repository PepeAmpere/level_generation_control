local MODULE_NAME = "Draw"
local ASSERT_PREFIX = "[" .. MODULE_NAME .. "] "

-- constants localization
-- local RENDER_FLIP_Y = MapExt.RENDER_FLIP_Y

-- functions localization
local FlipCoords2D = MapExt.FlipCoords2D

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
  Path = Path,
}