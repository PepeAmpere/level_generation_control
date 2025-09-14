local screenTypesDefs = {
  Eye = {
    defID = 1,
    mapScreen = true,
  },
  ElectroOptic = {
    defID = 2,
    mapScreen = true,
  },
  SAR = {
    defID = 3,
    mapScreen = true,
  },
  Grower = {
    defID = 4,
    mapScreen = true,
  },
  Builder = {
    defID = 5,
    mapScreen = true,
  },
  SaveLoad = {
    defID = 6,
    mapScreen = false,
    Preload = function()
      SavesStatus:UpdateSavesStatus()
    end,
  },
}

local screenTypesArray = {}
for hexType, def in pairs(screenTypesDefs) do
  screenTypesDefs[hexType].name = hexType
  screenTypesArray[def.defID] = screenTypesDefs[hexType]
end

for i,v in ipairs(screenTypesArray) do screenTypesDefs[i] = v end

return screenTypesDefs