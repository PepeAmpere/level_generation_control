local AI = {}
AI.__index = AI
setmetatable(AI, ComponentBase)

function AI.new()
  local i = setmetatable({}, AI) -- make new instance
  i.variables = {}
  return i
end

function AI:SetVariable(varName, value)
  self.variables[varName] = value
end

function AI:GetVariable(varName)
  return self.variables[varName]
end

return AI