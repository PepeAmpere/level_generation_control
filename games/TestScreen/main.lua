print("TestGameScreen")

INIT_FLOOR = 1
INIT_COLUMN = 2
CURRENT_SCREEN = Vec3(INIT_FLOOR, INIT_COLUMN, 0)
LASTKEY = ""
FPS_SIM = 10 -- frames per second for simulation
ADMIN = false

playerScreenMap = {
  {"empty", "intro", "empty"},
  {"map", "gameState", "facts"},
  {"map", "gameState", "facts"},
  {"empty", "outro", "empty"},
}
function GetScreenTypeName(position)
  local floor = position:X()
  local column = position:Y()
  return playerScreenMap[floor][column]
end
-- belongs to love section
ElementsDrawFns = {
  ControlDebug = function()
    UI2D.Begin("Sim info", 0, 400)
    UI2D.Label("Last key " .. LASTKEY)
    UI2D.End()
  end,
  GenericAdminStuff = function()
    ElementsDrawFns.ScreenType()
    ElementsDrawFns.ControlDebug()
  end,
  Position = function()
    UI2D.Begin("Position ", 400, 0)
    UI2D.Label("Position [" .. CURRENT_SCREEN.x .. "][" .. CURRENT_SCREEN.y .. "]")
    UI2D.End()
  end,
  ScreenType = function()
    UI2D.Begin("Adv. navigation", 0, 0)
    UI2D.Label("Screen name: " .. GetScreenTypeName(CURRENT_SCREEN))
    UI2D.End()
  end,
}
screenTypes = {
  empty = {
    reachable = false,
  },
  intro = {
    reachable = true,
    DrawFn = function()
      ElementsDrawFns.Position()
    end,
    DrawAdminFn = function()
      ElementsDrawFns.GenericAdminStuff()
    end,
  },
  gameState = {
    reachable = true,
    DrawFn = function()
      ElementsDrawFns.Position()
    end,
    DrawAdminFn = function()
      ElementsDrawFns.GenericAdminStuff()
    end,
  },
  map = {
    reachable = true,
    DrawFn = function()
      ElementsDrawFns.Position()
    end,
    DrawAdminFn = function()
      ElementsDrawFns.GenericAdminStuff()
    end,
  },
  facts = {
    reachable = true,
    DrawFn = function()
      ElementsDrawFns.Position()
    end,
    DrawAdminFn = function()
      ElementsDrawFns.GenericAdminStuff()
    end,
  },
  outro = {
    reachable = true,
    DrawFn = function()
      ElementsDrawFns.Position()
    end,
    DrawAdminFn = function()
      ElementsDrawFns.GenericAdminStuff()
    end,
  }
}

local MIN_FLOOR = 1
local MIN_COLUMN = 1
local MAX_FLOOR = #playerScreenMap
local MAX_COLUMN = #playerScreenMap[MIN_COLUMN]
local directions = {
  up = Vec3(-1,0,0),
  down = Vec3(1,0,0),
  left = Vec3(0,-1,0),
  right = Vec3(0,1,0),
}
function ScreenMove(direction)
  local newPosition = CURRENT_SCREEN + directions[direction]
  if newPosition:X() < MIN_FLOOR then return CURRENT_SCREEN end
  if newPosition:X() > MAX_FLOOR then return CURRENT_SCREEN end
  if newPosition:Y() < MIN_COLUMN then return CURRENT_SCREEN end
  if newPosition:Y() > MAX_COLUMN then return CURRENT_SCREEN end
  if screenTypes[GetScreenTypeName(newPosition)].reachable then
    return newPosition
  else
    return CURRENT_SCREEN
  end
end