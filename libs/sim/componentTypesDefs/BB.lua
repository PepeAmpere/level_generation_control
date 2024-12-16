local BB = {}
BB.__index = BB

function BB.New()
  local i = setmetatable({}, BB) -- make new instance
  i.variables = {}
  return i
end

function BB:SetVariable(varName, value)
  self.variables[varName] = value
end

function BB:Get()
  local tableCopy = {}
  for k, v in pairs(self.variables) do
    tableCopy[k] = v
  end
  return tableCopy
end

function BB:GetVariable(varName)
  return self.variables[varName]
end
return BB