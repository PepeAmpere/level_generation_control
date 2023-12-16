-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
-- libs

print(_VERSION)
if math.type then print(math.type(3)) end
if love then print(love.getVersion()) end

ArrayExt = require("libs.core.ArrayExt")
TableExt = require("libs.core.TableExt")

Vec3 = require("libs.core.Vec3")

Edge = require("libs.core.Edge")
Node = require("libs.core.Node")
Graph = require("libs.core.Graph")
Path = require("libs.core.Path")

MapExt = require("libs.map.MapExt") -- needed for Map & Tile to work
Tile = require("libs.map.Tile")
Map = require("libs.map.Map")

-- data
tileTypesDefs = require("data.tileTypes")
questTypesDefs = require("data.questTypes")

-- run the levele generation
levelMap = require ("libs.generator.questBasedGenerator")

-- ================================================================ --
-- ================================================================ --
-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal
local tileKey = MapExt.GetMapTileKey(Vec3(0, 0, 0))
TableExt.SaveToFile("levelMapExported.lua", levelMap.nodes)

-- BELOW JUST LOVE 2D debugging
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")

local DRAW_SIZE = 20000
local camera = Gamera.new(-DRAW_SIZE,-DRAW_SIZE,DRAW_SIZE,DRAW_SIZE)
local positionCenterX = 0
local positionCenterY = 0
camera:setWorld(-5000,-5000,DRAW_SIZE,DRAW_SIZE)
camera:setWindow(0,0,640,480)
camera:setPosition(positionCenterX, positionCenterY)

local UI_STATES = {
  pan = false,
}

function love.load()

end

function love.update(dt)
  if dt < 1/10 then
    love.timer.sleep(1/10 - dt)
  end
end

function love.draw()
  love.graphics.setBackgroundColor(192, 192, 192)
  --simple rectancle drawing in case we do error in the rest of the code
  --love.graphics.setColor(0, 255, 0)
  --love.graphics.rectangle("fill", 0, 0, 100, 100)

  camera:draw(DrawMap.AllTiles)
  -- camera:draw(DrawMap.AllPaths)
  camera:draw(DrawMap.AllNodes)
  camera:draw(DrawMap.AllEdges)
  -- camera:draw(draw.DrawPaths)
  -- camera:draw(draw.DrawProhibitedConnections)
  -- camera:draw(draw.DrawPassLevel)

  DrawMap.CameraAndCursorPosition(camera)
  DrawMap.DebugControl(camera)
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