gamepadDebug = {
  image = love.graphics.newImage("libs/input/f710.png")
}

local axisKeys = {
  "a1","a2", -- left stick
  "a3","a4", -- right stick
  "a5", -- left trigger
  "a6" -- right trigger
}

local axisNames = {
  a1 = "Lstick <>",
  a2 = "Lstick ^v",
  a3 = "Rstick <>",
  a4 = "Rstick ^v",
  a5 = "Ltrigger",
  a6 = "Rtrigger",
}

local gamepadIndex = {}
local gamepadMeta = {}
gamepadMeta.__index = gamepadIndex

local function new(ID)
  return setmetatable(
    {
      ID = ID or 1,
      states = {},
      axis = {},
    },
    gamepadMeta
  )
end

local Gamepad = new

function gamepadIndex:DrawDebug()
  if (self:IsConnected()) then
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("fill", 0, h-120, 180, 70)
    love.graphics.setColor(0, 0, 0, 1)
    local line = 0
    for _, axisKey in ipairs (axisKeys) do
      if self.axis[axisKey] then
        love.graphics.print(axisNames[axisKey] .. ": " .. self.axis[axisKey], 0, h-120+line*10)
      end
      line = line + 1
    end
    love.graphics.setColor(1,1,1)
    love.graphics.draw(
      gamepadDebug.image,
      10, h-50, -- x, y
      0, -- orientation (radians)
      0.2, 0.2 -- x, y scale
    )
  end
end

function gamepadIndex:GetID()
  return self.ID
end

function gamepadIndex:GetObject()
  local gamepads = love.joystick.getJoysticks()
   if gamepads[self.ID] then
    return gamepads[self.ID]
  end
  return nil
end


function gamepadIndex:GetLeftStickXY()
  if self.axis.a1 and self.axis.a2 then
    return self.axis.a1, self.axis.a2
  end
  return 0, 0
end

function gamepadIndex:GetRightStickXY()
  if self.axis.a3 and self.axis.a4 then
    return self.axis.a3, self.axis.a4
  end
  return 0, 0
end

function gamepadIndex:GetLeftTrigger()
  if self.axis.a5 then
    return self.axis.a5
  end
  return 0
end

function gamepadIndex:GetRightTrigger()
  if self.axis.a6 then
    return self.axis.a6
  end
  return 0
end

function gamepadIndex:InputAxis(camera, index, value)
  if math.abs(value) <= 0.06 then value = 0 end -- deadzone fix
  local axisKey = axisKeys[index]
  if self:IsConnected() then
    self.axis[axisKey] = value
  end
end

function gamepadIndex:IsConnected()
  local pad = self:GetObject()
  if pad then
    return true
  end
  return false
end

function gamepadIndex:IsPressed(key)
  local pad = self:GetObject()
  local now = pad:isGamepadDown({key})
  local state = self.states[key]

  if state then
    local last = state.last
    state.now = now
    return now and not last
  else
    state = {
      now = now,
      last = false,
    }
    return now
  end
end

function gamepadIndex:IsReleased(key)
  local pad = self:GetObject()
  local now = pad:isGamepadDown({key})
  local state = self.states[key]

  if state then
    local last = state.last
    state.now = now
    return not now and last
  else
    state = {
      now = now,
      last = false,
    }
    return now
  end
end

function gamepadIndex:UpdateKeyStates()
  for k, _ in pairs(self.states) do
    self.states[k].last = self.states[k].now
  end
end

return Gamepad
