local Visible = {}
Visible.__index = Visible
setmetatable(Visible, ComponentBase)

function Visible.new(params)
  local i = setmetatable({}, Visible) -- make new instance
  return i
end

return Visible