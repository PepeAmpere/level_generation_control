local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new()
  local i = setmetatable({}, ComponentBase) -- make new instance
  return i
end

function ComponentBase.load(componentData)
  local i = setmetatable({}, ComponentBase) -- make new instance
  for k,v in pairs(componentData) do
    i[k] = v
  end
  return i
end

function ComponentBase:Export(logLevel)
  return TableExt.Export(self)
end

return ComponentBase