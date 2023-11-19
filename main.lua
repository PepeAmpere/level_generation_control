-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
roomTypes = require("libs.rooms.roomTypes")

MapExt = require("libs.map.MapExt") -- needed for Map to work
Map = require("libs.map.Map")

-- run the levele generation
local levelMap = require ("libs.generator.generator")

-- saved on this level to avoid saving in Unreal
MapExt.SaveMapToFile("levelMapExported.lua", levelMap)

-- BELOW JUST LOVE 2D debugging
local draw = require("libs.draw.draw")
local gamera = require("libs.gamera.gamera")
local camera = gamera.new(-5000,-5000,5000,5000)
camera:setWorld(-5000,-5000,10000,10000)
camera:setWindow(0,0,1900,1000)
camera:setPosition(
	(0 + 900) * 0.5,
	(0 + 450) * 0.5
)
local UI_STATES = {
  pan = false,
}

function love.load()

end

function love.update(dt)
  if dt < 1/30 then
    love.timer.sleep(1/30 - dt)
  end
end

function love.draw()
  love.graphics.setBackgroundColor(255, 255, 255)
  --simple rectancle drawing in case we do error in the rest of the code
  --love.graphics.setColor(0, 255, 0)
  --love.graphics.rectangle("fill", 0, 0, 100, 100)
  
  camera:draw(draw.DrawRooms) 
  camera:draw(draw.DrawPaths)
  camera:draw(draw.DrawProhibitedConnections)
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
    local wx, wy = camera:getPosition()
    camera:setPosition(wx - dx, wy - dy)
  end
end