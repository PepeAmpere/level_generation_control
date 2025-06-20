print("TestHexMap in Love")

-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")

-- LOVE 2D Draw
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")
Keyboard = require("libs.input.Keyboard")
Gamepad = require("libs.input.Gamepad")

-- THIS PROJECT SPECIFIC
local path = GAME_PATH .. "engines.love"
DrawPrimitives = require(path .. ".DrawPrimitives")
Controls = require(path .. ".Controls")

local DRAW_SIZE = 10000
local camera = Gamera.new(-DRAW_SIZE, -DRAW_SIZE, DRAW_SIZE, DRAW_SIZE)
camera:setScale(1)

local positionCenterX = 0
local positionCenterY = 0
camera:setWorld(-2500, -2500, DRAW_SIZE, DRAW_SIZE)
camera:setWindow(0, 0, 800, 600)
camera:setPosition(positionCenterX, positionCenterY)

UI_STATES = {
  pan = false,
  textfields = {},
  sensorName = "Eye",
  scale = SCALE,
}

GamepadOne = Gamepad(1)
KeyboardOne = Keyboard()

function love.load()
end

function DrawStuff()
  local scale = UI_STATES.scale
  for _, node in pairs(levelMap.nodes) do
    DrawPrimitives.NodeShape(node, scale)

    simPosition = node:GetPosition()
    DrawPrimitives.Coordinates(simPosition, scale)
  end

  local step = OneSim:GetStep()
  local phaseStep = FPS_SIM

  DrawPrimitives.PersonAll(
    camera,
    UI_STATES.sensorName,
    (step % phaseStep)/phaseStep
  )
end

function love.update(dt)
  if dt < 1 / FPS_SIM then
    love.timer.sleep(1 / FPS_SIM - dt)
  end

  OneSim:Update(1)
  OneSim:UpdateTime(love.timer.getTime())

  -- lovebird.update()
  KeyboardOne:UpdateKeyStates()
  GamepadOne:UpdateKeyStates()
end

function love.draw()
  love.graphics.setBackgroundColor(192, 192, 192)

  camera:draw(DrawStuff)

  DrawMap.CameraAndCursorPosition(camera)
  DrawMap.DebugControl(camera)

  local x, y = GamepadOne:GetRightStickXY()
  --print("pan", x, y)
  DrawMap.PanMouse(camera, nil, nil, -x * 50, -y * 50, false)
  local x, y = GamepadOne:GetLeftStickXY()
  --print("zoom", x, y)
  DrawMap.PadZoom(camera, 0, -y)
  DrawMap.PadRotate(camera, -x, 0)

  GamepadOne:DrawDebug()

  local function DebugStep()
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print("Simstep: " .. OneSim:GetStep(), 600, 240)
    love.graphics.print("Simtime: " .. OneSim:GetTime(), 600, 260)
    love.graphics.print("SensorName: " .. UI_STATES.sensorName, 600, 280)
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

function love.keypressed(key, scancode)
  DrawMap.ControlKeys(camera, key, scancode)
end

--[[
function love.keyreleased(key, scancode)
DrawMap.ControlKeys(camera, key, scancode)
end
]]
   --

function love.keyreleased(key, scancode)
  LASTKEY = key
  local direction
  if key == "a" or key == "left" then direction = "left" end
  if key == "d" or key == "right" then direction = "right" end
  if key == "w" or key == "up" then direction = "up" end
  if key == "s" or key == "down" then direction = "down" end
  if key == "q" then ADMIN = not ADMIN end
end

function love.gamepadaxis(gamepad, axis, value)
  LASTKEY = axis .. " " .. value
  if axis == "triggerleft" and value == 1 then
    ADMIN = true
  else
    ADMIN = false
  end
  local inputtype, inputindex, hatdirection = gamepad:getGamepadMapping(axis)
  -- print(inputtype, inputindex, hatdirection, value)

  GamepadOne:InputAxis(inputindex, value)
  -- if inputindex == 3 then
  -- DrawMap.PanMouse(camera, nil, nil, -value*10, 0, istouch)
  -- end
  -- if inputindex == 4 then
  -- DrawMap.PanMouse(camera, nil, nil, 0 , -value*10 , istouch)
  -- end
end

function love.gamepadpressed(gamepad, button)
  print(button)
  Controls.JoystickButton(button)
end

function love.gamepadreleased(gamepad, button)
  LASTKEY = button
  mappingstring = gamepad:getGamepadMappingString()
  print(mappingstring)
  local direction
  if button == "dpleft" or button == "leftshoulder" then direction = "left" end
  if button == "dpright" or button == "rightshoulder" then direction = "right" end
  if button == "dpup" then direction = "up" end
  if button == "dpdown" then direction = "down" end
  DrawMap.ControlKeys(camera, LASTKEY, scancode)
end
