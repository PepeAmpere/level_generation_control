print("TestHexMap in Love")

-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")

local DRAW_SIZE = 10000
local camera = Gamera.new(-DRAW_SIZE,-DRAW_SIZE,DRAW_SIZE,DRAW_SIZE)
camera:setScale(1)

local positionCenterX = 0
local positionCenterY = 0
camera:setWorld(-2500,-2500,DRAW_SIZE,DRAW_SIZE)
camera:setWindow(0,0,800,600)
camera:setPosition(positionCenterX, positionCenterY)

local UI_STATES = {
  pan = false,
  textfields = {},
}

function love.load()
end
function DrawStuff()
  for _, node in pairs(levelMap.nodes) do
    -- Draw.Polygon(node:GetPosition(), {0, 0, 1, 0.5})
    local hexCoords = node:GetPosition()
    local q = hexCoords:X()
    local r = hexCoords:Y()
    --local s = hexCoords:Z()
    local scale = 100
    local vertical = 1.5 * scale
    local horizontal = math.sqrt(3) * scale
    local qUnit = Vec3(0,horizontal,0)
    local rUnit = Vec3(vertical,0.5*horizontal,0)
    --local sUnit = Vec3(vertical,-0.5*horizontal,0)
    local drawCoords = qUnit * q + rUnit * r
    local latestColor = {0.5, 1, 0.5, 0.5}
    Draw.Circle(
      "fill",
      drawCoords + correctionPoints[node:GetID()]*(scale/2.5),
      4,
      24,
      latestColor
    )
    local stringToWrite = tostring(hexCoords)
    if UI_STATES.textfields[stringToWrite] then
      latestColor = {0.5, 1, 0.5, 1}
      Draw.Text(
        UI_STATES.textfields[stringToWrite],
        drawCoords + Vec3(CENTER_X, ABOVE_NODE_Y, 0),
        latestColor
      )
    else
      local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
      UI_STATES.textfields[stringToWrite] = text
    end
  end
end

function love.update(dt)
  if dt < 1/FPS_SIM then
    love.timer.sleep(1/FPS_SIM - dt)
  end

  OneSim:Update(dt)
  OneSim:UpdateTime(love.timer.getTime())
  -- lovebird.update()
end

function love.draw()
  love.graphics.setBackgroundColor(192, 192, 192)

  camera:draw(DrawStuff)

  DrawMap.CameraAndCursorPosition(camera)
  DrawMap.DebugControl(camera)

  local function DebugStep()
    love.graphics.setColor(0,0,0,255)
    love.graphics.print("Simstep " .. OneSim.step, 400, 240)
    love.graphics.print("Simtime " .. OneSim.t, 400, 260)
  end
  DebugStep()
end

function love.mousepressed(x, y, button) 
  if button == 2 then -- right mouse button
    UI_STATES.pan = true
  end
end
function love.mousereleased(x, y, button)
  if button == 2 then -- right mouse button
    UI_STATES.pan = false
  end
end
function love.mousemoved(x, y, dx, dy, istouch)
  if UI_STATES.pan then
    DrawMap.PanMouse(camera, x, y, dx, dy, istouch)
  end
end

function love.wheelmoved(x, y)
  DrawMap.WheelZoom(camera, x, y)
end

function love.keyreleased(key, scancode)
  DrawMap.ControlKeys(camera, key, scancode)
end