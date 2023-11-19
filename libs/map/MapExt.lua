-- functions related to map maping which are not methods of the map object

local directions = {
  "north",
  "east",
  "south",
  "west"
}

local oppositionTable = {
  north = "south",
  east = "west",
  south = "north",
  west = "east"
}

local function CopyPath(path)
  local newPath = {}
  for i = 1, #path do
    newPath[i] = path[i]
  end
  return newPath
end

local function GetDirections()
  return directions
end

local function GetMapTileKey(x, z, minX, maxX, minZ, maxZ)
  if x < minX then return nil end
  if x > maxX then return nil end
  if z < minZ then return nil end
  if z > maxZ then return nil end
  return x .. "_" .. z
end

local function GetOppositeDirection(direction)
  return oppositionTable[direction]
end

local function MakePathString(path)
  local pathString = ""
  for i = 1, #path do
    pathString = pathString .. " " .. path[i]
  end

  return pathString
end

local function RandomizeDirection(directionsTable)
  local newDirectionTable = CopyPath(directionsTable)
  for i = #newDirectionTable, 2, -1 do
    local j = math.random(i)
    newDirectionTable[i], newDirectionTable[j] = newDirectionTable[j], newDirectionTable[i]
  end
  return newDirectionTable
end

local function WriteTableToFile(tbl, file, indent)
  indent = indent or 0
  local writeIndent = string.rep("  ", indent)

  if indent > 0 then
    file:write("{\n")
    -- file:write(writeIndent .. "{\n")
  else
    file:write("return {\n")
  end

  for key, value in pairs(tbl) do
    if type(key) == "string" then
      file:write(writeIndent .. "  [\"" .. key .. "\"] = ")
    else
      file:write(writeIndent .. "  [" .. tostring(key) .. "] = ")
    end
    if type(value) == "table" then
      WriteTableToFile(value, file, indent + 1)
    elseif type(value) == "string" then
      file:write(string.format("%q", value))
    else
      file:write(tostring(value))
    end
    file:write(",\n")
  end

  file:write(writeIndent .. "}")
end

local function SaveMapToFile(fileName, mapData)
  local file = io.open(fileName, "w")
  if file then
    WriteTableToFile(mapData, file, 0)
    file:close()
  else
    print("Error: could not open file for writing")
  end
end

return {
  CopyPath = CopyPath,
  GetDirections = GetDirections,
  GetMapTileKey = GetMapTileKey,
  GetOppositeDirection = GetOppositeDirection,
  MakePathString = MakePathString,
  RandomizeDirection = RandomizeDirection,
  SaveMapToFile = SaveMapToFile,
  WriteTableToFile = WriteTableToFile,
}