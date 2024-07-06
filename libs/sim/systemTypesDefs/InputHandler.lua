local HandleInputs = {}
HandleInputs.__index = HandleInputs

function HandleInputs.New()
local i = setmetatable({}, HandleInputs) -- make new instance
  return i
end

function HandleInputs:IsEntityValid(entity)
  if entity.components.Controller then
    return entity
  end
end

function HandleInputs:Run(entities)
  for _, entity in pairs(entities) do
  end
end

return HandleInputs