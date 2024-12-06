print("TestGameScreen")

local function MakeLightDef()
  return {
    R = math.random(1, 2) - 1,
    G = math.random(1, 2) - 1,
    B = math.random(1, 2) - 1,
  }
end

local function MakeLockDef()
  return {
    Up = MakeLightDef(),
    Right = MakeLightDef(),
    Down = MakeLightDef(),
    Left = MakeLightDef(),
  }
end

local function MatchRedComponent(lightDef)
  return lightDef.R == 1
end
local function MatchGreenComponent(lightDef)
  return lightDef.G == 1
end
local function MatchBlueComponent(lightDef)
  return lightDef.B == 1
end
local function MatchWhite(lightDef)
  return MatchRedComponent(lightDef) and
  MatchGreenComponent(lightDef) and
  MatchBlueComponent(lightDef)
end
local function MatchYellow(lightDef)
  return MatchRedComponent(lightDef) and
  MatchGreenComponent(lightDef) and
  lightDef.B == 0
end
local function MatchRed(lightDef)
  return MatchRedComponent(lightDef) and
  lightDef.G == 0 and
  lightDef.B == 0
end
local function MatchGreen(lightDef)
  return lightDef.R == 0 and
  MatchGreenComponent(lightDef) and
  lightDef.B == 0
end

local function MatchBlue(lightDef)
  return lightDef.R == 0 and
  lightDef.G == 0 and
  MatchBlueComponent(lightDef)
end

local function MatchCyan(lightDef)
  return lightDef.R == 0 and
  lightDef.G == 1 and
  MatchBlueComponent(lightDef)
end

local ComponentMatchToFnName = {
  Red = MatchRedComponent,
  Blue = MatchBlueComponent,
  Green = MatchGreenComponent,
}

local function CalculateComponentMatch(lockDef, color)
  local numberOfComponents = 0
  for direction, data in pairs(lockDef) do
    --print(color)
    if ComponentMatchToFnName[color](data) then numberOfComponents = numberOfComponents + 1 end
  end
  return "This lock has " .. numberOfComponents .. " components of color " .. color .. "  active."
end

local ColorMatchToFnName = {
  Red = MatchRed,
  Blue = MatchBlue,
  Green = MatchGreen,
  White = MatchWhite,
  Cyan = MatchCyan,
}

local function CalculateColorMatch(lockDef, color)
  local colorOccurences = 0
  for direction, data in pairs(lockDef) do
    --print(color)
    if ColorMatchToFnName[color](data) then colorOccurences = colorOccurences + 1 end
  end
  return "This lock has " .. colorOccurences .. " occurences of color " .. color .. "."
end

local function CalculateDirectionEnabled(lockDef, direction)
  local enabled = 0
  --print(direction)
  for color, value in pairs(lockDef[direction]) do
    if value == 1 then enabled = enabled + 1 end
  end
  return direction .. " part of lock has " .. enabled .. " components enabled."
end

local function MakeHints(lockDef)
  return {
    CalculateComponentMatch(lockDef, "Red"),
    CalculateDirectionEnabled(lockDef, "Down"),
    CalculateColorMatch(lockDef, "Red"),
    CalculateComponentMatch(lockDef, "Green"),
    CalculateColorMatch(lockDef, "White"),
    CalculateComponentMatch(lockDef, "Blue"),
    CalculateColorMatch(lockDef, "Green"),
    CalculateDirectionEnabled(lockDef, "Left"),
    CalculateColorMatch(lockDef, "Cyan"),
    CalculateColorMatch(lockDef, "Blue"),
    CalculateDirectionEnabled(lockDef, "Right"),
    CalculateDirectionEnabled(lockDef, "Up"),
  }
end

-- currently just simple dirty global value to parametrize this script
if SEED == nil then
  SEED = os.time()
end
math.randomseed(SEED)
local newDef = MakeLockDef()
local hints = MakeHints(newDef) or {}

print("DEF")
for direction, data in pairs(newDef) do
  local line = ""
  line = line .. direction .. " = new ColorInput { "
  for color, value in pairs(data) do
    line = line .. color .. " = " .. value .. ", "
  end
  line = line .. ("},")
  print(line)
end

-- print("\nHINTS")
local hintsLine = "Hints = new List<string> {"
for i, v in ipairs(hints) do
  hintsLine = hintsLine .. "\"" .. v .. "\",\n"
end
hintsLine = hintsLine .. "}"
print(hintsLine)

-- conversion to struct in unity
newDef.Hints = hints

-- unity type conversion hack
LOCK_DEF_UP_R = newDef.Up.R
LOCK_DEF_UP_G = newDef.Up.G
LOCK_DEF_UP_B = newDef.Up.B
LOCK_DEF_RIGHT_R = newDef.Right.R
LOCK_DEF_RIGHT_G = newDef.Right.G
LOCK_DEF_RIGHT_B = newDef.Right.B
LOCK_DEF_DOWN_R = newDef.Down.R
LOCK_DEF_DOWN_G = newDef.Down.G
LOCK_DEF_DOWN_B = newDef.Down.B
LOCK_DEF_LEFT_R = newDef.Left.R
LOCK_DEF_LEFT_G = newDef.Left.G
LOCK_DEF_LEFT_B = newDef.Left.B

return newDef