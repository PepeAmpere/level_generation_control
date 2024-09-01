local PatternMemoryLast = {}
PatternMemoryLast.__index = PatternMemoryLast

function PatternMemoryLast.New(params)
  params = params or {}
  local i = setmetatable({}, PatternMemoryLast) -- make new instance

  i.size = params.size or 1
  i.patternKey = params.patternKey or "patternKey"

  i.emptyPattern = params.emptyPattern or nil

  local lastPatterns = {}
  for mi = 1, i.size do
    lastPatterns[mi] = i.emptyPattern
  end
  i.lastPatterns = lastPatterns

  i.lastUsedMemoryIndex = 1

  return i
end

function PatternMemoryLast:Create(lastPattern)
  local newIndex = self.lastUsedMemoryIndex + 1
  if newIndex > self.size then
    newIndex = 1
  end

  self.lastPatterns[newIndex] = lastPattern
  self.lastUsedMemoryIndex = newIndex
end

function PatternMemoryLast:Get()
  return self.lastPatterns
end

function PatternMemoryLast:GetCounts()
  local countsTable = {}
  local initCount = 1
  local uniquePatterns = 0
  local allCount = 0
  local patternKey = self.patternKey
  for i=1, #self.lastPatterns do
    local patternOccurenceData = self.lastPatterns[i]
    local pattern = patternOccurenceData[patternKey]
    if pattern then
      if countsTable[pattern] ~= nil then
        countsTable[pattern] = countsTable[pattern] + 1
      else
        countsTable[pattern] = initCount
        uniquePatterns = uniquePatterns + 1
      end
      allCount = allCount + 1
    end
  end
  return countsTable, allCount, uniquePatterns
end

return PatternMemoryLast