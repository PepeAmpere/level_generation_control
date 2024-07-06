local Position = {}
Position.__index = Position

function Position.New(params)
  local i = setmetatable({}, Position) -- make new instance

  if params.position.x == nil then
    assert("[Position component]: " .. "position Vec3 not valid")
  end
  i.position = params.position
  return i
end

function Position:Get()
  return self.position
end

function Position:Set(position)
  self.position = position
end

return Position