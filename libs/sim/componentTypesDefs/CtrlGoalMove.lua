local CtrlGoalMove = {}
CtrlGoalMove.__index = CtrlGoalMove

function CtrlGoalMove.New(position)
  local i = setmetatable({}, CtrlGoalMove) -- make new instance
  i.position = position
  return i
end

function CtrlGoalMove:Get()
  return self.position
end

return CtrlGoalMove