local Simulation = {}
Simulation.__index = Simulation

function Simulation.New(step, startTime)
  local i = setmetatable({}, Simulation) -- make new instance
  i.step = step
  i.startTime = startTime -- outside constant
  i.t = 0
  return i
end

function Simulation:Update(dSteps)
  self.step = self.step + dSteps
end

function Simulation:UpdateTime(t)
  self.t = t - self.startTime
end

return Simulation