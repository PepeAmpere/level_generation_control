local UnrealEvent = {}

UnrealEvent.SaveMap = function()
  return JSON.encode(TableExt.Export(levelMap))
end

return UnrealEvent