local Position = {}
Position.__index = Position

function Position.New(params)
  local i = setmetatable({}, Position) -- make new instance
  i.position = params.vector
  return i
end

function Position:Get()
  return self.position
end

return Position