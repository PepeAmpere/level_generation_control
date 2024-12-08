-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
local myPath = "libs.lovr-ui2d"

local REAL_PATH = string.gsub(myPath, "%.", "%/")
local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

UI2D = require (myPath .. ".ui2d.ui2d")
DrawSimState = require (GAME_ENGINE_PATH .. ".draw.SimState")

function love.load()
  -- Initialize the library. You can optionally pass a font size. Default is 14.
  UI2D.Init( "love" )
end

function love.update( dt )
  -- This gets input information for the library.
  UI2D.InputInfo()

  -- sim step
  if dt < 1/FPS_SIM then
    love.timer.sleep(1/FPS_SIM - dt)
  end

  OneSim:Update(dt)
  OneSim:UpdateTime(love.timer.getTime())

  -- lovebird if desktop mode
  -- lovebird.update()
end

function love.draw()
  love.graphics.clear( 0.2, 0.2, 0.7 )

  -- Every window should be contained in a Begin/End block.
  DrawSimState.Widgets()
  DrawSimState.Timeline(0, 0)
  DrawSimState.TimeData(0, 100)
  -- DrawSimState.TimeData(math.ceil(WIDTH/2)-100, 75)


  -- This marks the end of the GUI.
  UI2D.RenderFrame()
end

function love.keypressed( key, scancode, isrepeat )
  UI2D.KeyPressed( key, isrepeat )
end

function love.textinput( text )
  UI2D.TextInput( text )
end

function love.keyreleased( key, scancode )
  UI2D.KeyReleased()
end

function love.wheelmoved( x, y )
  UI2D.WheelMoved( x, y )
end

print(_VERSION)
if math.type then print(math.type(3)) end
if love then print(love.getVersion()) end