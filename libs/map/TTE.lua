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
  local defaultMatcher = "ME"
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

    -- print(fullIndex,letterIndex, remainingString)
    if
      (
        fullIndex ~= nil and
        letterIndex == nil
      ) or
      (
        fullIndex ~= nil and
        fullIndex < letterIndex
      )
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

    print(s, step.Matcher, match, self.position, self.direction)
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

-- generic type-matching function
local function MatchType(levelMap, position, direction, tileType)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  if constructorTree:HasNodeID(tileID) then
    local tile = constructorTree:GetNode(tileID)
    return tile:IsTypeOf(tileType)
  end
  return false
end

-- Match Always
function TTE:MA()
  return true
end

-- Match any yellow
function TTE:MAY(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Undefined_yellow") or
        MatchType(levelMap, position, direction, "Virtual_yellow")
end

-- Match Empty
function TTE:ME(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  return not constructorTree:HasNodeID(tileID)
end

-- Match heading east
function TTE:MHE(levelMap, position, direction)
  return direction == "east"
end

-- Match heading north
function TTE:MHN(levelMap, position, direction)
  return direction == "north"
end

-- Match heading south
function TTE:MHS(levelMap, position, direction)
  return direction == "south"
end

-- Match heading west
function TTE:MHW(levelMap, position, direction)
  return direction == "west"
end

-- Match Undefined_blue
function TTE:MUB(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Undefined_blue")
end
-- Match Undefined_green
function TTE:MUG(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Undefined_green")
end
-- Match Undefined_red
function TTE:MUR(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Undefined_red")
end
-- Match Undefined_yellow
function TTE:MUY(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Undefined_yellow")
end

-- Match Virtual_blue
function TTE:MVB(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Virtual_blue")
end
-- Match Virtual_green
function TTE:MVG(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Virtual_green")
end
-- Match Virtual_red
function TTE:MVR(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Virtual_red")
end
-- Match Virtual_yellow
function TTE:MVY(levelMap, position, direction)
  return MatchType(levelMap, position, direction, "Virtual_yellow")
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

-- Transform to corners and corridors
function TTE:TCCV(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_corridor_vertical_M")
end
function TTE:TCturn_ES(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_ES_M")
end
function TTE:TCturn_NW(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_NW_M")
end
function TTE:TCturn_NE(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_NE_M")
end

-- Transform to BP_3x3_kitchen
function TTE:TRK(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_kitchen")
end

-- Transform to BP_3x3_office
function TTE:TRO(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_office")
end

-- Transform to BP_3x3_diner_entrance
function TTE:TRDE(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_diner_entrance")
end
-- Transform to BP_3x3_diner_table_area
function TTE:TRDT(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_diner_table_area")
end

-- Transform to BP_3x3_ritual_room
function TTE:TRR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_ritual_room")
end

-- Transform to BP_3x3_restroom_female
function TTE:TRRF(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_restroom_female")
end

-- Transform to BP_3x3_restroom_male
function TTE:TRRM(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_restroom_male")
end

-- Transform to Undefined_blue
function TTE:TUB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined_blue")
end
-- Transform to Undefined_green
function TTE:TUG(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined_green")
end
-- Transform to Undefined_red
function TTE:TUR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined_red")
end
-- Transform to Undefined_yellow
function TTE:TUY(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined_yellow")
end

-- Transform to Virtual_blue
function TTE:TVB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual_blue")
end
-- Transform to Virtual_green
function TTE:TVG(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual_green")
end
-- Transform to Virtual_red
function TTE:TVR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual_red")
end
-- Transform to Virtual_yellow
function TTE:TVY(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual_yellow")
end

-- Transform Zero = no transformation
function TTE:TZ(levelMap, position, direction, parentTile)
  return parentTile
end

return TTE