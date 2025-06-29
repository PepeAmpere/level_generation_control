local limits = {
  up = { -- indexes implicit from the order
    {min = 270, max = 330},
    {min = -30, max = 30},
    {min = 30, max = 90},
    {min = 90, max = 150},
    {min = 150, max = 210},
    {min = 210, max = 270},
  },
  down = {
    {min = 90, max = 150},
    {min = 150, max = 210},
    {min = 210, max = 270},
    {min = 270, max = 330},
    {min = -30, max = 30},
    {min = 30, max = 90},
  },
  right = {
    {min = 180, max = 240},
    {min = 240, max = 300},
    {min = 300, max = 360},
    {min = 0, max = 60},
    {min = 60, max = 120},
    {min = 120, max = 180},
  },
  left = {
    {min = 0, max = 60},
    {min = 60, max = 120},
    {min = 120, max = 180},
    {min = 180, max = 240},
    {min = 240, max = 300},
    {min = 300, max = 360},
  },
}
local function SelectIndex(direction, degrees)
  local ourLimis = limits[direction]
  for index=1, #ourLimis do
    local currentLimit = ourLimis[index]
    if
      (degrees >= currentLimit.min and degrees <= currentLimit.max) or
      (degrees-360 >= currentLimit.min and degrees-360 <= currentLimit.max)
    then
      return index
    end
  end
end

local function UpdateHexSelection(camera, direction)
  local angle = camera:getAngle()
  local degrees = ((((angle) * 180 / math.pi) % 360) + 360) % 360
  local selectedHexPosition = levelMap:GetAnyHexPosition(UI_STATES.selectedHexKey, "_")

  -- later move to map drawing
  local x1,y1,x2,y2,x3,y3,x4,y4 = camera:getVisibleCorners()
  local x,y = selectedHexPosition:ToPixel()

  local directionIndex = SelectIndex(direction, degrees)
  print(direction, degrees, "=>", directionIndex)
  local newHexPosition = selectedHexPosition:Neighbor(directionIndex, 1)
  UI_STATES.selectedHexKey = newHexPosition:ToKey()
end

local leftshoulderMap = {
  Eye = "SAR",
  SAR = "ElectroOptic",
  ElectroOptic = "Eye"
}
local rightshoulderMap = {
  Eye = "ElectroOptic",
  SAR = "Eye",
  ElectroOptic = "SAR"
}
local nodeTypeSwitchMap = {
  mapDesert = "mapField",
  mapField = "mapForest",
  mapForest = "mapSea",
  mapSea = "mapDesert"
}
local ButtonFunctions = {
  a = function()
    local selectedNode = levelMap:GetNode(UI_STATES.selectedHexKey)
    if selectedNode ~= nil then
      local typeName = selectedNode:GetTagValue("hexTypeName")
      if typeName then
        selectedNode:SetTagValue("hexTypeName", nodeTypeSwitchMap[typeName])
      end
    end
  end,
  back = function() UI_STATES.debugOn = not UI_STATES.debugOn end,
  backspace = function() UI_STATES.debugOn = not UI_STATES.debugOn end,
  dpdown = function (camera) UpdateHexSelection(camera, "down") end,
  dpleft = function (camera) UpdateHexSelection(camera, "left") end,
  dpright = function (camera) UpdateHexSelection(camera, "right") end,
  dpup = function (camera) UpdateHexSelection(camera, "up") end,
  kp2 = function (camera) UpdateHexSelection(camera, "down") end,
  kp4 = function (camera) UpdateHexSelection(camera, "left") end,
  kp6 = function (camera) UpdateHexSelection(camera, "right") end,
  kp8 = function (camera) UpdateHexSelection(camera, "up") end,
  leftshoulder = function() UI_STATES.sensorName = leftshoulderMap[UI_STATES.sensorName] end,
  rightshoulder = function() UI_STATES.sensorName = rightshoulderMap[UI_STATES.sensorName] end,
  kp7 = function() UI_STATES.sensorName = leftshoulderMap[UI_STATES.sensorName] end,
  kp9 = function() UI_STATES.sensorName = rightshoulderMap[UI_STATES.sensorName] end,
  tab = function(camera)
    local width, height, mode = love.window.getMode()
    local count = love.window.getDisplayCount()
    local displayIndex = mode.display
    displayIndex = displayIndex + 1
    if displayIndex > 2 then displayIndex = 1 end
    love.window.setPosition( 0, 0, displayIndex )
  end,
  escape = function(camera)
    UI_STATES.modes = love.window.getFullscreenModes(count)
    table.sort(UI_STATES.modes, function(a, b) return a.width*a.height > b.width*b.height end)
    print(#UI_STATES.modes)
    local screenMode = love.window.getFullscreen()
    local modeIndex = 1
    if screenMode then
      for index, mode in ipairs(UI_STATES.modes) do if mode.height < 1000 then modeIndex = index break end end
    end
    if not screenMode then
      for index, mode in ipairs(UI_STATES.modes) do if mode.width <= 1920 then modeIndex = index break end end
    end
    love.window.updateMode( UI_STATES.modes[modeIndex].width, UI_STATES.modes[modeIndex].height, {
      fullscreen = not screenMode,
      fullscreentype = "exclusive",
    })
    camera:setWindow(0, 0, UI_STATES.modes[modeIndex].width, UI_STATES.modes[modeIndex].height)
  end,
  ["`"] = function(camera) print("AboveTabButton") end,
}

return {
  JoystickButton = function(camera, gamepad, button)
    if ButtonFunctions[button] then
      ButtonFunctions[button](camera)
    end
  end,

  KeyboardButton = function(camera, key)
    if ButtonFunctions[key] then
      ButtonFunctions[key](camera)
    end
  end,
}