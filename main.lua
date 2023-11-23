-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
-- data
roomTypes = require("libs.rooms.roomTypes")

-- libs
Vec3 = require("libs.core.vec3.Vec3")
MapExt = require("libs.map.MapExt") -- needed for Map to work
Map = require("libs.map.Map")

-- run the levele generation
local levelMap = require ("libs.generator.generator")

-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal
MapExt.SaveMapToFile("levelMapExported.lua", levelMap)

-- BELOW JUST LOVE 2D debugging
local draw = require("libs.draw.draw")
local gamera = require("libs.gamera.gamera")
local camera = gamera.new(-5000,-5000,5000,5000)
local positionCenterX = 900
local positionCenterY = 450
camera:setWorld(-5000,-5000,10000,10000)
camera:setWindow(0,0,1900,1000)
camera:setPosition(
	(0 + positionCenterX) * 0.5,
	(0 + positionCenterY) * 0.5
)
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
  love.graphics.setBackgroundColor(255, 255, 255)
  --simple rectancle drawing in case we do error in the rest of the code
  --love.graphics.setColor(0, 255, 0)
  --love.graphics.rectangle("fill", 0, 0, 100, 100)
  
  camera:draw(draw.DrawRooms) 
  camera:draw(draw.DrawPaths)
  camera:draw(draw.DrawProhibitedConnections)
  camera:draw(draw.DrawPassLevel)
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

function love.wheelmoved(x, y)
  local mx,my = love.mouse.getPosition()
  if y > 0 then
    camera:setScale(camera:getScale()+0.05)
  elseif y < 0 then
    camera:setScale(camera:getScale()-0.05)
  end
  camera:setPosition(mx,my)
end