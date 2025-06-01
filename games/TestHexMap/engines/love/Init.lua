print("TestHexMap in Love")

-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")
Keyboard = require("libs.input.Keyboard")
Gamepad = require("libs.input.Gamepad")

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

GamepadOne = Gamepad(1)
KeyboardOne = Keyboard()

function love.load()
end
function DrawStuff()
for _, node in pairs(levelMap.nodes) do
  -- Draw.Polygon(node:GetPosition(), {0, 0, 1, 0.5})
  local hexCoords = node:GetPosition()
  local scale = 100

  local x,y = hexCoords:ToPixel(scale)
  local drawCoords = Vec3(x,y,0)
  local vertices = hexCoords:ToCorners(scale, scale*0.8)

  local latestColor = {0.5, 1, 0.5, 0.5}
  Draw.Polygon(
    vertices,
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
KeyboardOne:UpdateKeyStates()
GamepadOne:UpdateKeyStates()
end

function love.draw()
love.graphics.setBackgroundColor(192, 192, 192)

camera:draw(DrawStuff)

DrawMap.CameraAndCursorPosition(camera)
DrawMap.DebugControl(camera)

local x,y = GamepadOne:GetRightStickXY()
--print("pan", x, y)
DrawMap.PanMouse(camera, nil, nil, -x*50, -y*50, false)
local x,y = GamepadOne:GetLeftStickXY()
--print("zoom", x, y)
DrawMap.PadZoom(camera, 0, -y)
DrawMap.PadRotate(camera, -x, 0)

GamepadOne:DrawDebug()

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

function love.keypressed(key, scancode)
DrawMap.ControlKeys(camera, key, scancode)
end
--[[
function love.keyreleased(key, scancode)
DrawMap.ControlKeys(camera, key, scancode)
end
]]--

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
local inputtype, inputindex, hatdirection = gamepad:getGamepadMapping( axis )
-- print(inputtype, inputindex, hatdirection, value)

GamepadOne:InputAxis(inputindex, value)
-- if inputindex == 3 then
-- DrawMap.PanMouse(camera, nil, nil, -value*10, 0, istouch)
-- end
-- if inputindex == 4 then
-- DrawMap.PanMouse(camera, nil, nil, 0 , -value*10 , istouch)
-- end
end
function love.gamepadpressed( gamepad, button)
print(button)
end
function love.gamepadreleased( gamepad, button )
LASTKEY = button
mappingstring = gamepad:getGamepadMappingString( )
print(mappingstring)
local direction
if button == "dpleft" or button == "leftshoulder" then direction = "left" end
if button == "dpright" or button == "rightshoulder" then direction = "right" end
if button == "dpup" then direction = "up" end
if button == "dpdown" then direction = "down" end
DrawMap.ControlKeys(camera, LASTKEY, scancode)
end