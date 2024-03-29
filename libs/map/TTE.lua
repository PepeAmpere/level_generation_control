local DIRECTIONS = MapExt.DIRECTIONS
local OPPOSITION_TABLE = MapExt.OPPOSITION_TABLE
local DIR_TO_VEC3 = MapExt.DIR_TO_VEC3
local ROTATION_LEFT = MapExt.ROTATION_LEFT
local ROTATION_RIGHT = MapExt.ROTATION_RIGHT
local DIRECTION_TO_SIDES = MapExt.DIRECTION_TO_SIDES
local DIRECTIONS_TO_TILES_STRICT = MapExt.DIRECTIONS_TO_TILES_STRICT

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
  i.stepIndex = 0     -- not started

  i.branchPoints = {} -- key => {position = Vec3, direction = <dir>, parentID = nodeID}

  customMethods = customMethods or {}
  for k, v in pairs(customMethods) do
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
  for i = 1, string.len(formula) do
    if remainingString == nil or remainingString == "" then
      break
    end
    -- replace all full step-formulas with underscore
    local defWithoutFull = string.gsub(remainingString, matchFormulaFull, "_")
    -- check what is the index of the first "full formula"
    local fullIndex = string.find(remainingString, matchFormulaFull)
    -- check what is the index of the first "single letter movement"
    local letterIndex = string.find(defWithoutFull, matchSingleLetters)
    -- print(fullIndex,letterIndex, remainingString)

    -- based on findings populate the next step
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
      remainingString = string.sub(remainingString, eI + 1)

      steps[i] = {
        MovementType = moveType,
        Matcher = matcherType,         -- in case of P and Q movements, BPname is saved here instead
        Transformer = transformerType, -- in case of P and Q movements, BPname is saved here instead
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
-- movements
function TTE:F()
  return self:Move(1)
end

function TTE:L()
  self.direction = ROTATION_LEFT[self.direction]
end

function TTE:P(BPName)
  self.branchPoints[BPName] = {
    position = self.position,
    direction = self.direction,
  }
end

function TTE:Q(BPName)
  local BPData = self.branchPoints[BPName]
  self.position = BPData.position
  self.direction = BPData.direction
end

function TTE:R()
  self.direction = ROTATION_RIGHT[self.direction]
end

function TTE:W() -- wait, no movement or rotation
end

-- matching & transforming
function TTE:Match(levelMap)
  local steps = DecodeFormula(self.formula)
  local result = true
  -- print(self.formula)

  for s = 1, #steps do
    self.stepIndex = s
    local step = steps[s]
    local match = true

    -- print(s, step.MovementType, step.Matcher, match, self.position, self.direction)
    if step.MovementType == "P" or step.MovementType == "Q" then
      TTE[step.MovementType](self, step.Matcher)
    else
      -- simple moves
      TTE[step.MovementType](self)
      match = TTE[step.Matcher](self, levelMap, self.position, self.direction)
    end
    -- print(s, step.MovementType, step.Matcher, match, self.position, self.direction)

    if not match then
      result = false
      break
    end
  end
  return result
end

local function GetMoveVector(direction, stepSize)
  return DIR_TO_VEC3[direction] * stepSize
end

function TTE:Move(steps)
  local direction = self.direction
  if steps < 0 then direction = OPPOSITION_TABLE[direction] end

  local moveVector = GetMoveVector(direction, self.stepSize) * math.abs(steps)

  self.position = self.position + moveVector
end

function TTE:Transform(levelMap, startTile)
  local steps = DecodeFormula(self.formula)
  local listOfParents = { startTile }
  local tileIDtoParentTile = {} -- tileID => parentTile

  -- DebugDecodedFormula(steps)

  for s = 1, #steps do
    self.stepIndex = s
    local step = steps[s]

    if step.MovementType == "P" then
      TTE[step.MovementType](self, step.Transformer)
      local currentPositionTileID = GetMapTileKey(self.position)
      tileIDtoParentTile[currentPositionTileID] = listOfParents[#listOfParents]
    elseif step.MovementType == "Q" then
      TTE[step.MovementType](self, step.Transformer)
      local currentPositionTileID = GetMapTileKey(self.position)
      listOfParents[#listOfParents + 1] = tileIDtoParentTile[currentPositionTileID]
    else
      local lastParent = listOfParents[#listOfParents]

      TTE[step.MovementType](self)

      local tile = TTE[step.Transformer](
        self,
        levelMap,
        self.position,
        self.direction,
        lastParent
      )

      if not tile:IsEqual(lastParent) then
        listOfParents[#listOfParents + 1] = tile
      end

      -- count trasnformers
      levelMap:ConstructionIncrementTransformerCounter(step.Transformer)
    end
  end

  -- count formula
  levelMap:ConstructionIncrementFormulaMatchCounter(self.formula)
end

-- EXAMPLE BUILT-IN MATCHERS
-- all methods can be later added in the "new" method via custom param "customMethods"
-- now hard-defining here to keep it simple

-- generic type-matching function
local function MatchTagsAll(levelMap, position, tags)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  local match = true

  if constructorTree:HasNodeID(tileID) then
    local tile = constructorTree:GetNode(tileID)
    for _, tag in ipairs(tags) do
      if not tile:HasTag(tag) then
        match = false
        break
      end
    end
  else
    return false
  end
  return match
end

local function MatchType(levelMap, position, tileType)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  if constructorTree:HasNodeID(tileID) then
    local tile = constructorTree:GetNode(tileID)
    return tile:IsTypeOf(tileType)
  end
  return false
end

-- Match Any
function TTE:MA()
  return true
end

function TTE:MAY(levelMap, position, direction)
  return MatchTagsAll(levelMap, position, {"yellow"})
end
function TTE:MAB(levelMap, position, direction)
  return MatchTagsAll(levelMap, position, {"blue"})
end

-- Match Empty
function TTE:ME(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  return not constructorTree:HasNodeID(tileID)
end

local function MatchExitCount(levelMap, position, direction, exitCount)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  local children = constructorTree:GetNodeIDChildren(tileID)
  return #children == exitCount
end

local function MatchUndefined(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
end

local function MatchVirtual(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
end

function TTE:MAEX(levelMap, position, direction)
  return MatchExitCount(levelMap, position, direction, 0)
end

function TTE:MAEXX(levelMap, position, direction)
  return MatchExitCount(levelMap, position, direction, 1)
end

function TTE:MAEXXX(levelMap, position, direction)
  return MatchExitCount(levelMap, position, direction, 2)
end

function TTE:MAEXXXX(levelMap, position, direction)
  return MatchExitCount(levelMap, position, direction, 30)
end

function TTE:MUEX(levelMap, position, direction)
  return MatchUndefined(levelMap, position, direction) and
      MatchExitCount(levelMap, position, direction, 0)
end

function TTE:MUEXX(levelMap, position, direction)
  return MatchUndefined(levelMap, position, direction) and
      MatchExitCount(levelMap, position, direction, 1)
end

function TTE:MUEXXX(levelMap, position, direction)
  return MatchUndefined(levelMap, position, direction) and
      MatchExitCount(levelMap, position, direction, 2)
end

function TTE:MUEXXXX(levelMap, position, direction)
  return MatchUndefined(levelMap, position, direction) and
      MatchExitCount(levelMap, position, direction, 3)
end

function TTE:MUV(levelMap, position, direction)
  return (
      MatchUndefined(levelMap, position, direction) or
      MatchVirtual(levelMap, position, direction)
    )
end

function TTE:MUVEX(levelMap, position, direction)
  return (
      MatchUndefined(levelMap, position, direction) or
      MatchVirtual(levelMap, position, direction)
    ) and
    MatchExitCount(levelMap, position, direction, 0)
end

function TTE:MUVEXX(levelMap, position, direction)
  return (
      MatchUndefined(levelMap, position, direction) or
      MatchVirtual(levelMap, position, direction)
    ) and
    MatchExitCount(levelMap, position, direction, 1)
end

function TTE:MUVEXXX(levelMap, position, direction)
  return (
      MatchUndefined(levelMap, position, direction) or
      MatchVirtual(levelMap, position, direction)
    ) and
    MatchExitCount(levelMap, position, direction, 2)
end

function TTE:MUVEXXXX(levelMap, position, direction)
  return (
      MatchUndefined(levelMap, position, direction) or
      MatchVirtual(levelMap, position, direction)
    ) and
    MatchExitCount(levelMap, position, direction, 3)
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

-- Match relative back
function TTE:MrelB(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local constructorTree = levelMap:GetConstructorTree()
  local parentID = constructorTree:GetParentOfID(tileID)

  if parentID ~= nil then
    return true
  end
  return false
end

-- Match relative forward
function TTE:MrelF(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local forwardTilePosition = position + GetMoveVector(direction, self.stepSize)
  local forwardTileID = GetMapTileKey(forwardTilePosition)

  local constructorTree = levelMap:GetConstructorTree()
  return constructorTree:HasNodeIDChildID(tileID, forwardTileID)
end

-- Match relative left
function TTE:MrelL(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local leftDirection = ROTATION_LEFT[direction]
  local forwardTilePosition = position + GetMoveVector(leftDirection, self.stepSize)
  local forwardTileID = GetMapTileKey(forwardTilePosition)

  local constructorTree = levelMap:GetConstructorTree()
  return constructorTree:HasNodeIDChildID(tileID, forwardTileID)
end

-- Match relative right
function TTE:MrelR(levelMap, position, direction)
  local tileID = GetMapTileKey(position)
  local leftDirection = ROTATION_RIGHT[direction]
  local forwardTilePosition = position + GetMoveVector(leftDirection, self.stepSize)
  local forwardTileID = GetMapTileKey(forwardTilePosition)

  local constructorTree = levelMap:GetConstructorTree()
  return constructorTree:HasNodeIDChildID(tileID, forwardTileID)
end

function TTE:MU(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
end

function TTE:MUB(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
  and MatchTagsAll(levelMap, position, {"blue"})
end

function TTE:MUG(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
  and MatchTagsAll(levelMap, position, {"green"})
end

function TTE:MUR(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
  and MatchTagsAll(levelMap, position, {"red"})
end

function TTE:MUY(levelMap, position, direction)
  return MatchType(levelMap, position, "Undefined")
  and MatchTagsAll(levelMap, position, {"yellow"})
end

function TTE:MV(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
end

function TTE:MVB(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
  and MatchTagsAll(levelMap, position, {"blue"})
end

function TTE:MVG(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
  and MatchTagsAll(levelMap, position, {"green"})
end

function TTE:MVR(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
  and MatchTagsAll(levelMap, position, {"red"})
end

function TTE:MVY(levelMap, position, direction)
  return MatchType(levelMap, position, "Virtual")
  and MatchTagsAll(levelMap, position, {"yellow"})
end

-- Generic transformation function
local function GenericTransform(levelMap, position, direction, parentTile, tileType, tags)
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
  for _, tag in ipairs(tags or {}) do
    tile:SetTag(tag)
  end

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
function TTE:TCG(levelMap, position, direction, parentTile)
  local transformKey = ""
  local directionsOrder = { "N", "E", "S", "W" }
  local directionFunctions = DIRECTION_TO_SIDES[direction]

  for _, currentDirection in ipairs(directionsOrder) do
    local functionName = directionFunctions[currentDirection]
    if self[functionName](self, levelMap, position, direction) then
      transformKey = transformKey .. currentDirection
    end
  end

  local tileType = DIRECTIONS_TO_TILES_STRICT[transformKey]

  return GenericTransform(levelMap, position, direction, parentTile, tileType)
end

function TTE:TCC(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_base_crossroad")
end

function TTE:TCCV(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_corridor_vertical_M")
end

function TTE:TCCH(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_corridor_horizontal_M")
end

function TTE:TCCHB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_corridor_horizontal_M_boxes")
end

function TTE:TCEN(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_end_N_M")
end

function TTE:TCES(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_end_S_M")
end

function TTE:TCturnES(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_ES_M")
end

function TTE:TCturnNW(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_NW_M")
end

function TTE:TCturnNE(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_turn_NE_M")
end

function TTE:TRC(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_candleRoom", {"blue","candleSpawn"})
end

function TTE:TRE(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_exit_door_R_E_M")
end

function TTE:TRK(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_kitchen")
end

function TTE:TRO(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_office")
end

function TTE:TRDE(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_diner_entrance")
end

function TTE:TRDT(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_diner_table_area")
end

function TTE:TRR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_ritual_room", {"blue", "sp"})
end

function TTE:TRRLZ(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_ritual_room_firstEscape", {"blue", "sp"})
end

function TTE:TRRB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_ritual_room_blocked", {"blue", "sp"})
end

function TTE:TRRF(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_restroom_female")
end

function TTE:TRRM(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "BP_3x3_restroom_male")
end

function TTE:TUB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined", {"blue"})
end

function TTE:TUG(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined", {"green"})
end

function TTE:TUR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined", {"red"})
end

function TTE:TUY(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Undefined", {"yellow"})
end

function TTE:TVB(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual", {"blue"})
end

function TTE:TVG(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual", {"green"})
end

function TTE:TVR(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual", {"red"})
end

function TTE:TVY(levelMap, position, direction, parentTile)
  return GenericTransform(levelMap, position, direction, parentTile, "Virtual", {"yellow"})
end

-- Transform Zero = no transformation
function TTE:TZ(levelMap, position, direction, parentTile)
  return parentTile
end

return TTE
