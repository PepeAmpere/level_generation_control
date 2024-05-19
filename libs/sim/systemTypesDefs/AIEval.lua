local AIEval = {}
AIEval.__index = AIEval

function AIEval.New()
local i = setmetatable({}, AIEval) -- make new instance
  return i
end

function AIEval:IsEntityValid(entity)
  if entity.components.AI then
    return true
  end
  return false
end

function AIEval:Run(entities)
  for _, entity in pairs(entities) do
    print("AIEval: " .. entity:GetID())
  end
end

return AIEval