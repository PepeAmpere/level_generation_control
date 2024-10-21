-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")
Turtle = require("libs.turtle.turtle")

-- data
images = require(GAME_PATH .. "data.imagesInit")

local DRAW_SIZE = 40000
local camera = Gamera.new(-DRAW_SIZE,-DRAW_SIZE,DRAW_SIZE,DRAW_SIZE)
camera:setScale(0.02)

local positionCenterX = 0
local positionCenterY = 0
camera:setWorld(-10000,-10000,DRAW_SIZE,DRAW_SIZE)
camera:setWindow(0,0,800,600)
camera:setPosition(positionCenterX, positionCenterY)

local UI_STATES = {
  pan = false,
}

triangle = Turtle(300,0)
levelToDraw = Turtle()
TurtleBuilder = require("libs.turtle.TurtleBuilder")

function love.load()
  triangle:pensize(10):forward(100):left(120):forward(100):left(120):forward(100)
  levelString = "1111[11[1[0]0]1[0]0]11[1[0]0]1[0]0"
  levelToDraw = TurtleBuilder.Encode(levelToDraw, levelString)
end
function DrawStuff()
  triangle:draw()
  levelToDraw:draw()
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

  --simple rectancle drawing in case we do error in the rest of the code
  --love.graphics.setColor(0, 255, 0)
  --love.graphics.rectangle("fill", 0, 0, 100, 100)

  --camera:draw(DrawStuff)

  --camera:draw(DrawMap.AllTiles)
  camera:draw(DrawMap.AllTreeTiles)
  camera:draw(DrawMap.AllTreeLines)
  camera:draw(DrawMap.AllNodes)
  camera:draw(DrawMap.AllEdges)
  camera:draw(DrawMap.AllPaths)
  camera:draw(DrawMap.AllTileRestrictions)

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