local keyboardIndex = {}
local keyboardMeta = {}
keyboardMeta.__index = keyboardIndex

local function new()
  return setmetatable(
    {
      states = {}
    },
    keyboardMeta
  )
end

function keyboardIndex:IsPressed(key)
  local now = love.keyboard.isDown(key)
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

function keyboardIndex:IsReleased(key)
  local now = love.keyboard.isDown(key)
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

function keyboardIndex:UpdateKeyStates()
  for k, _ in pairs(self.states) do
    self.states[k].last = self.states[k].now
  end
end

local Keyboard = new

return Keyboard