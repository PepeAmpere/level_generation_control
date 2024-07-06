local Visible = {}
Visible.__index = Visible

function Visible.New(params)
  local i = setmetatable({}, Visible) -- make new instance
  return i
end

return Visible