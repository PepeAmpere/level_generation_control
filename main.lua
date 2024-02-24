-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
-- libs

ArrayExt = require("libs.core.ArrayExt")
TableExt = require("libs.core.TableExt")

Vec3 = require("libs.core.Vec3")

Edge = require("libs.core.Edge")
Node = require("libs.core.Node")
Graph = require("libs.core.Graph")
Path = require("libs.core.Path")
Tree = require("libs.core.Tree")

MapExt = require("libs.map.MapExt") -- needed for Map & Tile to work
Tile = require("libs.map.Tile")
Map = require("libs.map.Map")
TTE = require("libs.map.TTE")

UnrealEvent = require("libs.unreal.UnrealEvent")
JSON = require("libs.json.json")

-- data
tileTypesDefs = require("data.tileTypes")
local qResult = require("data.questTypes")
questTypes = qResult[1]
questTypesDefs = qResult[2]
local pResult = require("data.productionRules")
productionRulesTypes = pResult[1]
productionRulesDefs = pResult[2]

-- prepare the level generation
math.randomseed( os.time() )
local MapMakingFunction = require ("libs.generator.questBasedGenerator")

-- run the level generation once
levelMap = MapMakingFunction()

-- ================================================================ --
-- ================================================================ --
-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal

--[[
print(_VERSION)
if math.type then print(math.type(3)) end
if love then print(love.getVersion()) end
]]--

-- local tileKey = MapExt.GetMapTileKey(Vec3(0, 0, 0))

-- simplified export
--[[
local exportTable = UnrealEvent.SaveMap()
local jsonString = JSON.encode(exportTable)
TableExt.SaveToFile("levelMapExported.lua", {json = jsonString})
TableExt.SaveToFile("levelMapExported.lua", exportTable)
]]--

-- BELOW JUST LOVE 2D debugging
-- lovebird = require("libs.lovebird.init")
Colors = require("libs.drawLove.Colors")
Draw = require("libs.drawLove.Draw")
DrawMap = require("libs.drawLove.DrawMap")
Gamera = require("libs.gamera.gamera")
Turtle = require("libs.turtle.turtle")

-- data
images = require("data.imagesInit")

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
  if dt < 1/10 then
    love.timer.sleep(1/10 - dt)
  end
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