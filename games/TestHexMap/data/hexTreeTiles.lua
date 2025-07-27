local base = "G"
local alphabeth = { "O", "x" }
local maxI = 1
local maxO = 5
local maxSteps = 6

local function GetPositionIndex(posIndex, increment, steps)
  local newIndex = posIndex + increment
  if newIndex > steps then
    newIndex = newIndex - steps
  end
  return newIndex
end

local function GenerateFinalString(combinationArray)
  local finalString = ""
  for i = 1, #combinationArray do
    finalString = finalString .. combinationArray[i]
  end
  return finalString
end

local function GenerateNextOX(currentString, step, results)
  if step < maxSteps then
    for a = 1, #alphabeth do
      GenerateNextOX(currentString .. alphabeth[a], step + 1, results)
    end
  else
    results[#results + 1] = currentString
  end
end

local function RotateStringRight(string, remainingRotations)
  if remainingRotations > 0 then
    local newString = string:sub(2) .. string:sub(1, 1)
    return RotateStringRight(newString, remainingRotations - 1)
  else
    return string
  end
end

local results = {}
GenerateNextOX("", 1, results)

local finalTiles = {}
local counter = 0
for _, result in ipairs(results) do
  -- print(result)
  for s = 0, maxSteps - 1 do
    local newFinalString = RotateStringRight("I" .. result, s)
    local newKey = base .. newFinalString
    if not finalTiles[newKey] then
      local t = {}
      newFinalString:gsub(".", function(c) table.insert(t, c) end)
      finalTiles[newKey] = {
        drawTable = t,
        -- rotation of string to the right means opposite rotation in practice
        rotationRight = base .. RotateStringRight("I" .. result, s + maxSteps - 1),
        rotationLeft = base .. RotateStringRight("I" .. result, s + 1),
      }
      counter = counter + 1
    end
  end
end

local hexTypesArray = {}
local hexTreeTilesDefs = {}
for tileKey, definition in pairs(finalTiles) do
  local newDefID = #hexTypesArray+1
  hexTreeTilesDefs[tileKey] = {
    defID = newDefID,
    drawDefs = {
      color = { 0.9, 0.9, 0.9, 1 },
      drawTable = definition.drawTable
    },
    name = tileKey,
    rotationRight = definition.rotationRight,
    rotationLeft = definition.rotationLeft,
  }
  hexTypesArray[newDefID] = hexTreeTilesDefs[tileKey]
end

for i,v in ipairs(hexTypesArray) do hexTreeTilesDefs[i] = v end

return hexTreeTilesDefs
