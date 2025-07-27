local sensorTypesDefs = {
  Builder = {
    defID = 1,
  },
  Grower = {
    defID = 2

  },
  Eye = {
    defID = 3

  },
  ElectroOptic = {
    defID = 4

  },
  SAR = {
    defID = 5

  },
}

local sensorTypesArray = {}
for hexType, def in pairs(sensorTypesDefs) do
  sensorTypesDefs[hexType].name = hexType
  sensorTypesArray[def.defID] = sensorTypesDefs[hexType]
end

for i,v in ipairs(sensorTypesArray) do sensorTypesDefs[i] = v end

return sensorTypesDefs