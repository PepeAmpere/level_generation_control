local CtrlTask = {}
CtrlTask.__index = CtrlTask
setmetatable(CtrlTask, ComponentBase)

function CtrlTask.new(task)
  local i = setmetatable({}, CtrlTask) -- make new instance
  i.task = task
  return i
end

function CtrlTask:Get()
  return self.task
end

return CtrlTask