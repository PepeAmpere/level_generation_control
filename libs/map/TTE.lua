local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3

-- functions localization
local GetMapTileKey = MapExt.GetMapTileKey

local TTE = {}
TTE.__index = TTE

function TTE.new(position, direction, stepSize, formula, customMethods)
  local i = setmetatable({}, TTE) -- make new instance
  i.position = position
  i.direction = direction
  i.stepSize = stepSize
  i.formula = formula
  i.pathIndex = 0 -- not started

  customMethods = customMethods or {}
  for k,v in pairs(customMethods) do
    i[k] = v
  end

  return i
end

-- LOCAL NOT EXPOSED FUNCTIONS
local function DecodeFormula(formula)
  local steps = {}
  local defaultMatcher = "MA"
  local defaultTransformer = "TZ"

  local matchFormulaFull = "%a%(%a+,%a+%)"
  local fullBreakout = "(%a)%((%a+),(%a+)%)"
  local matchSingleLetters = "%a"
  local remainingString = formula
  for i=1, string.len(formula) do
    if remainingString == nil or remainingString == "" then
      break
    end
    local defWithoutFull = string.gsub(remainingString, matchFormulaFull, "_")
    local fullIndex = string.find(remainingString, matchFormulaFull)
    local letterIndex = string.find(defWithoutFull, matchSingleLetters)
    if
      (
        fullIndex ~= nil and
        letterIndex == nil
      ) or
      fullIndex < letterIndex
    then
      _, eI, moveType, matcherType, transformerType = string.find(
        remainingString,
        fullBreakout
      )
      remainingString = string.sub(remainingString, eI+1)
      steps[i] = {
        MovementType = moveType,
        Matcher = matcherType,
        Transformer = transformerType,
      }
    else
      local letterString = string.sub(remainingString, 1, 1)
      remainingString = string.sub(remainingString, 2)
      steps[i] = {
        MovementType = letterString,
        Matcher = defaultMatcher,
        Transformer = defaultTransformer,
      }
    end
    -- print(steps[i].MovementType, steps[i].Matcher, steps[i].Transformer)
  end

  return steps
end

local function DebugDecodedFormula(steps)
  for _, step in ipairs(steps) do
    print(step.MovementType, step.Matcher, step.Transformer)
  end
end

-- EXPOSED BASIC METHODS
function TTE:F()
  return self:Move(1)
end

--[[ function TTE:ExploreEmpty(levelMap)
  local path = self.formula
  local result = true

  for i=1, string.len(path) do
    self:OneStep()
    local tileID = GetMapTileKey(self.position)
    local constructorTree = levelMap:GetConstructorTree()
    if constructorTree:HasNodeID(tileID) then
      result = false
      break
    end
  end
  return result
end ]]--

function TTE:L()
  if self.direction == "north" then
    self.direction = "west"
  elseif self.direction == "west" then
    self.direction = "south"
  elseif self.direction == "south" then
    self.direction = "east"
  elseif self.direction == "east" then
    self.direction = "north"
  end
end

function TTE:Match(levelMap)
  local steps = DecodeFormula(self.formula)
  local result = true

  for s=1, #steps do
    self.pathIndex = s
    local step = steps[s]
    TTE[step.MovementType](self)

    local match = TTE[step.Matcher](self, levelMap, self.position, self.direction)
    if not match then
      result = false
      break
    end
  end
  return result
end

function TTE:Move(steps)
  local direction = self.direction
  if steps < 0 then direction = OPPOSITION_TABLE[direction] end

  local moveVector = DIR_TO_VEC3[direction] * math.abs(steps) * self.stepSize

  self.position = self.position + moveVector
end

function TTE:R()
  if self.direction == "north" then
    self.direction = "east"
  elseif self.direction == "east" then
    self.direction = "south"
  elseif self.direction == "south" then
    self.direction = "west"
  elseif self.direction == "west" then
    self.direction = "north"
  end
end

function TTE:Transform(levelMap, startTile)
  local steps = DecodeFormula(self.formula)
  local listOfParents = {startTile}
  -- DebugDecodedFormula(steps)

  for s=1, #steps do
    self.pathIndex = s
    local step = steps[s]
    TTE[step.MovementType](self)

    local lastParent = listOfParents[#listOfParents]
    local tile = TTE[step.Transformer](
      self,
      levelMap,
      self.position,
      self.direction,
      lastParent
    )

    -- check if we added a new unique tile
    if not tile:IsEqual(lastParent) then
     listOfParents[#listOfParents+1] = tile
    end
  end
end

function TTE:W() -- wait, no movement or rotation
  return
end

-- EXAMPLE BUILT-IN MATCHERS
-- all methods can be later added in the "new" method via custom param "customMethods"
-- now hard-defining here to keep it simple
-- Match Auto
function TTE:MA()
  return true
end

-- Match Empty
function TTE:ME(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  return not constructorTree:HasNodeID(tileID)
end

-- Match Undefined_yellow
function TTE:MUY(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  if constructorTree:HasNodeID(tileID) then
    local tile = constructorTree:GetNode(tileID)
    return tile:IsTypeOf("Undefined_yellow")
  end
  return false
end

-- Match Virtual_yellow
function TTE:MVY(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  if constructorTree:HasNodeID(tileID) then
    local tile = constructorTree:GetNode(tileID)
    return tile:IsTypeOf("Virtual_yellow")
  end
  return false
end

-- Generic transformation function
local function GenericTransform(levelMap, position, direction, parentTile, tileType)
  local scores = levelMap:ConstructionGetScoresCopy()
  local currentIterationTag = "t" .. scores.iterations -- prevent infinite recursion

  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()

  local tile
  local tileCreated = false

  if constructorTree:HasNodeID(tileID) then
    tile = constructorTree:GetNode(tileID)
    tile:SetType(tileType)
  else
    tile = Tile.newFromNode(
      Node.new(
        tileID,
        position,
        tileType,
        {
          tile = true,
          [currentIterationTag] = true,
        }
      ),
      levelMap.tileSize
    )
    tileCreated = true
  end

  tile:SetTag(currentIterationTag)

  if tileCreated then
    constructorTree:AddNode(tile, parentTile)
  end

  local parentDirection = parentTile:GetDirectionOf(tile)
  local tileDirection = OPPOSITION_TABLE[parentDirection]
  if not tile:IsEqual(parentTile) then
    parentTile:SetRestriction(parentDirection, 2)
    tile:SetRestriction(tileDirection, 2)
  end

  return tile
end

-- Transform to Undefined_yellow
function TTE:TUY(levelMap, position, direction, parentTile)
  return GenericTransform(
    levelMap,
    position,
    direction,
    parentTile,
    "Undefined_yellow"
  )
end

-- Transform to Virtual_yellow
function TTE:TVY(levelMap, position, direction, parentTile)
  return GenericTransform(
    levelMap,
    position,
    direction,
    parentTile,
    "Virtual_yellow"
  )
end

-- Transform Zero = no transformation
function TTE:TZ(levelMap, position, direction, parentTile)
  return parentTile
end

return TTE