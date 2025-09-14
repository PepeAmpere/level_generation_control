local Position = {}
Position.__index = Position
setmetatable(Position, ComponentBase)

function Position.new(params)
  local i = setmetatable({}, Position) -- make new instance

  if
    params.position.x == nil and
    params.position.r == nil
  then
    assert("[Position component]: " .. "position not valid, not Vec3 nor Hex3")
  end
  i.position = params.position
  return i
end

function Position.load(componentData)
  local i = setmetatable({}, Position) -- make new instance

  i.position = load(componentData.position)()
  return i
end

function Position:Get()
  return self.position
end

function Position:Set(position)
  self.position = position
end

return Position