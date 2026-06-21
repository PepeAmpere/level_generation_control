print("TestLoveLoad")

local myPath = "libs.lovr-ui2d"

local REAL_PATH = string.gsub(myPath, "%.", "%/")
local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

UI2D = require(myPath .. ".ui2d.ui2d")

-- THIS PROJECT SPECIFIC
local path = GAME_PATH .. "engines.love"
Controls = require(path .. ".Controls")

function love.load()
  -- Initialize the library. You can optionally pass a font size. Default is 14.
  UI2D.Init("love")
end

function love.update(dt)
  -- simstep
  if dt < 1 / FPS_SIM then
    love.timer.sleep(1 / FPS_SIM - dt)

    if AUTOPLAY then
      local time = love.timer.getTime()
      OneSim:Update(dt)
      OneSim:UpdateTime(time)
      
      if lastStep < math.floor(time) then
        lastStep = math.floor(time)
        SimulateAllTransfers()
      end
    end
  end

  -- This gets input information for the library.
  UI2D.InputInfo()

  -- lovebird if desktop mode
  -- lovebird.update()
end

function love.draw()
  love.graphics.clear(0.2, 0.2, 0.1)

  -- Basic screen layout
  DrawFunction = screenTypes[GetScreenTypeName(CURRENT_SCREEN)].DrawFn()

  -- This marks the end of the GUI.
  UI2D.RenderFrame()
end

function love.textinput( text, code )
  UI2D.TextInput( text )
end

function love.keyreleased(key, scancode)
  LASTKEY = key
  local direction
  if key == "a" or key == "left" then direction = "left" end
  if key == "d" or key == "right" then direction = "right" end
  if key == "w" or key == "up" then direction = "up" end
  if key == "s" or key == "down" then direction = "down" end
  if direction then CURRENT_SCREEN = ScreenMove(direction) end
  if key == "q" then ADMIN = not ADMIN end
end

function love.gamepadaxis(joystick, axis, value)
  LASTKEY = axis .. " " .. value
  if axis == "triggerleft" and value == 1 then
    ADMIN = true
  else
    ADMIN = false
  end
end

function love.gamepadreleased(joystick, button)
  LASTKEY = button
  local direction
  if button == "dpleft" or button == "leftshoulder" then direction = "left" end
  if button == "dpright" or button == "rightshoulder" then direction = "right" end
  if button == "dpup" then direction = "up" end
  if button == "dpdown" then direction = "down" end
  if direction then CURRENT_SCREEN = ScreenMove(direction) end
end
