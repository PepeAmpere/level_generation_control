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

local function ShallowCopy(tbl)
  local tblCopy = {}
  for key, value in pairs(tbl) do
    tblCopy[key] = value
  end
  return tblCopy
end

return {
  SaveToFile = SaveToFile,
  ShallowCopy = ShallowCopy,
  WriteUsingFunction = WriteUsingFunction,
}