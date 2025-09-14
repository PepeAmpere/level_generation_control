local function DeepCopy(tbl, seen)
  if (type(tbl) ~= "table") then return tbl end
  if (seen and seen[tbl]) then return seen[tbl] end

  local newSeen = seen or {}
  local newTable = setmetatable({}, getmetatable(tbl))

  newSeen[tbl] = newTable
  for k, v in pairs(tbl) do 
    newTable[DeepCopy(k, newSeen)] = DeepCopy(v, newSeen)
  end
  return newTable
end

local function Export(tbl)
  local newTable = {}
  for key, value in pairs(tbl) do
    if type(value) ~= "table" then
      newTable[key] = value
    else
      local ExportMethod = value.Export
      -- print(ExportMethod, key, value)
      if ExportMethod then
        -- print(tbl, key, value, value.Export, type(value:Export(value)))
        newTable[key] = value:Export(value)
      else
        newTable[key] = Export(value)
      end
    end
  end
  return newTable
end

local function Extend(tbl, ...)
  if tbl == nil then tbl = {} end
  for _, extension in ipairs({...}) do
    for key, value in pairs(extension) do
      tbl[key] = value
    end
  end
  return tbl
end

local function GetRandomKey(tbl)
  local keys = {}
  for key, _ in pairs(tbl) do
    keys[#keys + 1] = key
  end
  return keys[math.random(#keys)]
end

local function GetRandomValue(tbl)
  return tbl[GetRandomKey(tbl)]
end

local function ShallowCopy(tbl)
  local tblCopy = {}
  for key, value in pairs(tbl) do
    tblCopy[key] = value
  end
  return tblCopy
end

local function ValuesToArray(tbl)
  local newArray = {}
  for _,v in pairs(tbl) do
    newArray[#newArray + 1] = v
  end
  return newArray
end

local function WriteUsingFunction(tbl, WriteFunction, indent)
  indent = indent or 0
  local writeIndent = string.rep("  ", indent)

  if indent > 0 then
    WriteFunction("{\n")
    -- file:write(writeIndent .. "{\n")
  else
    WriteFunction("return {\n")
  end

  for key, value in pairs(tbl) do
    if type(key) == "string" then
      WriteFunction(writeIndent .. "  [\"" .. key .. "\"] = ")
    else
      WriteFunction(writeIndent .. "  [" .. tostring(key) .. "] = ")
    end
    if
      type(value) == "table" and
      indent <= 5 -- preventing infinite recursion
    then
      WriteUsingFunction(value, WriteFunction, indent + 1)
    elseif type(value) == "string" then
      WriteFunction(string.format("%q", value))
    else
      WriteFunction(tostring(value))
    end
    WriteFunction(",\n")
  end

  WriteFunction(writeIndent .. "}")
end

local function SaveToFile(fileName, tbl)
  local file = io.open(fileName, "w")

  -- workaround for offline run
  if file == nil then file = io.open("client/" .. fileName, "w") end

  if file then
    local function WriteToFile(stringToWrite)
      file:write(stringToWrite)
    end
    WriteUsingFunction(tbl, WriteToFile, 0)
    file:close()
  else
    print("Error: could not open file for writing")
  end
end

return {
  DeepCopy = DeepCopy,
  Export = Export,
  Extend = Extend,
  GetRandomKey = GetRandomKey,
  GetRandomValue = GetRandomValue,
  SaveToFile = SaveToFile,
  ShallowCopy = ShallowCopy,
  ValuesToArray = ValuesToArray,
  WriteUsingFunction = WriteUsingFunction,
}