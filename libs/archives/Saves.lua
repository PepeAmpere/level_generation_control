local Saves = {}
Saves.__index = Saves

function Saves.new(path)
  local i = setmetatable({}, Saves) -- make new instance
  i.savesPath = path
  i.fileNames = {
    "save001",
    "save002",
    "save003",
    "save004",
    "save005",
    "save006",
    "save007",
    "save008",
    "save009",
  }
  -- later make this object
  i.saveStatus = {
    save001 = { fileExist = false },
    save002 = { fileExist = false },
    save003 = { fileExist = false },
    save004 = { fileExist = false },
    save005 = { fileExist = false },
    save006 = { fileExist = false },
    save007 = { fileExist = false },
    save008 = { fileExist = false },
    save009 = { fileExist = false },
  }
  i.selectedIndex = 1
  return i
end

function Saves:GetFiles()
  local fileNames = self.fileNames
  local files = {}
  for _, fileName in ipairs(fileNames) do
    local filePath = self.savesPath .. "." .. fileName
    local file = LuaExt.TryRequire(filePath)
    if file then
      local newIndex = #fileNames + 1
      files[newIndex] = file
      files[fileName] = files[newIndex]
    end
  end
  return files
end

function Saves:GetFileSlots()
  local fileNames = self.fileNames
  local fileSlots = {}
  for _, fileName in ipairs(fileNames) do
    local filePath = self.savesPath .. "." .. fileName
    fileSlots[#fileSlots + 1] = filePath
  end
  return fileSlots
end

function Saves:GetSlotsStatus()
  local fileNames = self.fileNames
  local status = {}
  for i, fileName in ipairs(fileNames) do
    status[i] = self.saveStatus[fileName].fileExist
  end
  return status
end

function Saves:HasAnySaves()
  return #self:GetFiles() > 0
end

function Saves:GetSelectedSaveIndex()
  return self.selectedIndex
end

function Saves:GetSelectedSaveFile()
  return (self.savesPath .. "." .. self.fileNames[self.selectedIndex])
end

function Saves:SelextNext()
  local nextIndex = self.selectedIndex + 1
  if nextIndex > #self.fileNames then nextIndex = 1 end
  self.selectedIndex = nextIndex
end

function Saves:SelectPrevious()
  local nextIndex = self.selectedIndex - 1
  if nextIndex < 1 then nextIndex = #self.fileNames end
  self.selectedIndex = nextIndex
end

function Saves:UpdateSavesStatus()
  local fileNames = self.fileNames
  for _, fileName in ipairs(fileNames) do
    local filePath = self.savesPath .. "." .. fileName
    local file = LuaExt.TryRequire(filePath)
    if file then
      self.saveStatus[fileName].fileExist = true
    else
      self.saveStatus[fileName].fileExist = false
    end
  end
end

return Saves
