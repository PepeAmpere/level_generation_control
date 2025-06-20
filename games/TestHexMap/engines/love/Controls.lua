return {
  JoystickButton = function(button)
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
    local ButtonFunctions = {
      leftshoulder = function()
        UI_STATES.sensorName = leftshoulderMap[UI_STATES.sensorName]
      end,
      rightshoulder = function()
        UI_STATES.sensorName = rightshoulderMap[UI_STATES.sensorName]
      end,
    }

    if ButtonFunctions[button] then
      ButtonFunctions[button]()
    end
  end
}