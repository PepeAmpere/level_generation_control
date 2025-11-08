local limits = {
  up = { -- indexes implicit from the order
    { min = 270, max = 330 },
    { min = -30, max = 30 },
    { min = 30,  max = 90 },
    { min = 90,  max = 150 },
    { min = 150, max = 210 },
    { min = 210, max = 270 },
  },
  down = {
    { min = 90,  max = 150 },
    { min = 150, max = 210 },
    { min = 210, max = 270 },
    { min = 270, max = 330 },
    { min = -30, max = 30 },
    { min = 30,  max = 90 },
  },
  right = {
    { min = 180, max = 240 },
    { min = 240, max = 300 },
    { min = 300, max = 360 },
    { min = 0,   max = 60 },
    { min = 60,  max = 120 },
    { min = 120, max = 180 },
  },
  left = {
    { min = 0,   max = 60 },
    { min = 60,  max = 120 },
    { min = 120, max = 180 },
    { min = 180, max = 240 },
    { min = 240, max = 300 },
    { min = 300, max = 360 },
  },
}
local function SelectIndex(direction, degrees)
  local ourLimis = limits[direction]
  for index = 1, #ourLimis do
    local currentLimit = ourLimis[index]
    if
        (degrees >= currentLimit.min and degrees <= currentLimit.max) or
        (degrees - 360 >= currentLimit.min and degrees - 360 <= currentLimit.max)
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
  local scale = levelMap:GetSale()
  local x1, y1, x2, y2, x3, y3, x4, y4 = camera:getVisibleCorners()
  local x, y = selectedHexPosition:ToPixel(scale)

  local directionIndex = SelectIndex(direction, degrees)
  print(direction, degrees, "=>", directionIndex)
  local newHexPosition = selectedHexPosition:Neighbor(directionIndex, 1)
  UI_STATES.selectedHexKey = newHexPosition:ToKey()
end

local function GetSwitchRight(tbl, currentValue)
  local index = tbl[currentValue].defID
  index = index + 1
  if index > #tbl then index = 1 end
  return tbl[index].name
end

local function GetSwitchLeft(tbl, currentValue)
  local index = tbl[currentValue].defID
  index = index - 1
  if index < 1 then index = #tbl end
  return tbl[index].name
end

local SimulationControl = {

  ChangeHexTypeRight = function()
    local selectedNode = levelMap:GetNode(UI_STATES.selectedHexKey)
    if selectedNode ~= nil then
      local typeName = selectedNode:GetTagValue("hexTypeName")
      if typeName then
        selectedNode:SetTagValue("hexTypeName", GetSwitchRight(HexTypesDefs, typeName))
      end
    end
  end,

  ChangeHexTypeLeft = function()
    local selectedNode = levelMap:GetNode(UI_STATES.selectedHexKey)
    if selectedNode ~= nil then
      local typeName = selectedNode:GetTagValue("hexTypeName")
      if typeName then
        selectedNode:SetTagValue("hexTypeName", GetSwitchLeft(HexTypesDefs, typeName))
      end
    end
  end,

  IncreaseRotateLeft = function(camera, value)
    if value > 0.001 then
      UI_STATES.rotateLeftSum = UI_STATES.rotateLeftSum + value * 0.2
      if UI_STATES.rotateLeftSum > 1 then
        UI_STATES.rotateLeftSum = UI_STATES.rotateLeftSum - 1
        levelMap:RotateHexLeft(UI_STATES.selectedHexKey, "hexTreeTile")
      end
    end
  end,

  IncreaseRotateRight = function(camera, value)
    if value > 0.001 then
      UI_STATES.rotateRightSum = UI_STATES.rotateRightSum + value * 0.2
      if UI_STATES.rotateRightSum > 1 then
        UI_STATES.rotateRightSum = UI_STATES.rotateRightSum - 1
        levelMap:RotateHexRight(UI_STATES.selectedHexKey, "hexTreeTile")
      end
    end
  end,

  RotateHexLeft = function()
    levelMap:RotateHexLeft(UI_STATES.selectedHexKey, "hexTreeTile")
  end,

  RotateHexRight = function()
    levelMap:RotateHexRight(UI_STATES.selectedHexKey, "hexTreeTile")
  end,

  DebugOnOff = function() UI_STATES.debugOn = not UI_STATES.debugOn end,
  FourDirectionSelectionDown = function(camera) UpdateHexSelection(camera, "down") end,
  FourDirectionSelectionLeft = function(camera) UpdateHexSelection(camera, "left") end,
  FourDirectionSelectionRight = function(camera) UpdateHexSelection(camera, "right") end,
  FourDirectionSelectionUp = function(camera) UpdateHexSelection(camera, "up") end,

  Save = function()
    local fileName = SavesStatus:GetSelectedSaveFile()
    fileName = (string.gsub(fileName, "%.", "/") .. ".lua")
    local simExport = OneSim:Export("warning")

    -- JSON.encode(TableExt.Export(simExport))
    -- local jsonString = JSON.encode(simExport)
    TableExt.SaveToFile(fileName, simExport)
    -- TableExt.SaveToFile("games/levelMapExported.lua", simExport)
    SavesStatus:UpdateSavesStatus()
  end,

  Load = function()
    local fileName = SavesStatus:GetSelectedSaveFile()
    print("Loading: " .. fileName)

    for packageName, _ in pairs(package.loaded) do
      if
          string.find(packageName, fileName)
      then
        -- print("Unloading " .. packageName)
        package.loaded[packageName] = nil
      end
    end
    local loadedTable = LuaExt.TryRequire(fileName)
    OneSim = Simulation.load(loadedTable)
    levelMap = OneSim.systems.HexMap -- shortcut
  end,

  SelectScreenLeft = function()
    UI_STATES.screenName = GetSwitchLeft(ScreenTypesDefs, UI_STATES.screenName)
    if ScreenTypesDefs[UI_STATES.screenName].Preload then
      ScreenTypesDefs[UI_STATES.screenName].Preload()
    end
  end,

  SelectScreenRight = function()
    UI_STATES.screenName = GetSwitchRight(ScreenTypesDefs, UI_STATES.screenName)
    if ScreenTypesDefs[UI_STATES.screenName].Preload then
      ScreenTypesDefs[UI_STATES.screenName].Preload()
    end
  end,

  SwitchDisplay = function(camera)
    local width, height, mode = love.window.getMode()
    local count = love.window.getDisplayCount()
    local displayIndex = mode.display
    displayIndex = displayIndex + 1
    if displayIndex > 2 then displayIndex = 1 end
    love.window.setPosition(0, 0, displayIndex)
  end,

  -- works only for the primary monitor
  FullDisplay = function(camera)
    UI_STATES.modes = love.window.getFullscreenModes(count)
    table.sort(UI_STATES.modes, function(a, b) return a.width * a.height > b.width * b.height end)
    print(#UI_STATES.modes)
    local displayMode = love.window.getFullscreen()
    local modeIndex = 1
    if displayMode then
      for index, mode in ipairs(UI_STATES.modes) do
        if mode.height < 1000 then
          modeIndex = index
          break
        end
      end
    end
    if not displayMode then
      for index, mode in ipairs(UI_STATES.modes) do
        if mode.width <= 1920 then
          modeIndex = index
          break
        end
      end
    end
    love.window.updateMode(UI_STATES.modes[modeIndex].width, UI_STATES.modes[modeIndex].height, {
      fullscreen = not displayMode,
      fullscreentype = "exclusive",
    })
    camera:setWindow(0, 0, UI_STATES.modes[modeIndex].width, UI_STATES.modes[modeIndex].height)
  end,

  TestControl = function(camera) print("TestControl") end,
}

local globalControls = {
  back = SimulationControl.DebugOnOff,
  backspace = SimulationControl.DebugOnOff,
  dpdown = SimulationControl.FourDirectionSelectionDown,
  dpleft = SimulationControl.FourDirectionSelectionLeft,
  dpright = SimulationControl.FourDirectionSelectionRight,
  dpup = SimulationControl.FourDirectionSelectionUp,
  kp2 = SimulationControl.FourDirectionSelectionDown,
  kp4 = SimulationControl.FourDirectionSelectionLeft,
  kp6 = SimulationControl.FourDirectionSelectionRight,
  kp8 = SimulationControl.FourDirectionSelectionUp,
  leftshoulder = SimulationControl.SelectScreenLeft,
  rightshoulder = SimulationControl.SelectScreenRight,
  kp7 = SimulationControl.SelectScreenLeft,
  kp9 = SimulationControl.SelectScreenRight,
  tab = SimulationControl.SwitchDisplay,
  escape = SimulationControl.FullDisplay,
}

local ScreenToControl = {
  Builder = TableExt.Extend(
    {},
    globalControls,
    {
      a = SimulationControl.ChangeHexTypeRight,
      b = SimulationControl.ChangeHexTypeLeft,
      a5 = SimulationControl.IncreaseRotateLeft,
      a6 = SimulationControl.IncreaseRotateRight,
      x = SimulationControl.RotateHexLeft,
      y = SimulationControl.RotateHexRight,
      ["`"] = SimulationControl.TestControl,
    }
  ),
  Grower = TableExt.Extend({}, globalControls),
  Eye = TableExt.Extend({}, globalControls),
  ElectroOptic = TableExt.Extend({}, globalControls),
  SAR = TableExt.Extend({}, globalControls),
  SaveLoad = TableExt.Extend(
    {},
    globalControls,
    {
      a = function() SimulationControl.Save() end,
      x = function() SimulationControl.Load() end,
      dpup = function() SavesStatus:SelectPrevious() end,
      dpdown = function() SavesStatus:SelextNext() end,
      kp2 = function() SavesStatus:SelextNext() end,
      kp8 = function() SavesStatus:SelectPrevious() end,
    }
  ),
}

return {
  JoystickButton = function(camera, gamepad, button)
    local screenName = UI_STATES.screenName
    if
        ScreenToControl[screenName] and
        ScreenToControl[screenName][button]
    then
      ScreenToControl[screenName][button](camera)
    end
  end,

  JoystickTrigger = function(camera, gamepad, button, value)
    local screenName = UI_STATES.screenName
    if
        ScreenToControl[screenName] and
        ScreenToControl[screenName][button]
    then
      ScreenToControl[screenName][button](camera, value)
    end
  end,

  KeyboardButton = function(camera, key)
    local screenName = UI_STATES.screenName
    if
        ScreenToControl[screenName] and
        ScreenToControl[screenName][key]
    then
      ScreenToControl[screenName][key](camera)
    end
  end,
}
