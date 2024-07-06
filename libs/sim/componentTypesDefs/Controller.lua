local Controller = {}
Controller.__index = Controller

function Controller.New()
  local i = setmetatable({}, Controller) -- make new instance
  i.action = "none"
  i.actionParams = {}
  return i
end

function Controller:SetAction(actionName, actionParams)
  self.action = actionName
  self.actionParams = actionParams
end

return Controller