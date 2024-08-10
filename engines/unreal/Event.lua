-- to speedup and simplify, just one sim referenced via global OneSim

local Event = {}

Event.SimulateSystem = function(simulationID, entities, systemName, params)
  return true
end

-- currently not generic, tailored to TheDarkShift game
Event.SaveMap = function()
  return JSON.encode(TableExt.Export(levelMap))
end

return Event