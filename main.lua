-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
-- libs

LuaExt = require("libs.core.LuaExt")

ArrayExt = require("libs.core.ArrayExt")
TableExt = require("libs.core.TableExt")

Vec3 = require("libs.core.Vec3")

Edge = require("libs.core.Edge")
Node = require("libs.core.Node")
Graph = require("libs.core.Graph")
Path = require("libs.core.Path")
Tree = require("libs.core.Tree")

JSON = require("libs.json.json")

MapExt = require("libs.map.MapExt") -- needed for Map & Tile to work
Tile = require("libs.map.Tile")
Map = require("libs.map.Map")
TTE = require("libs.map.TTE")

-- GAME SELECTION
GAME = "LightLock"
GAME_PATH = "games." .. GAME .. "."
Game = require(GAME_PATH .. "main") -- main.lua of the game

-- ENGINE SELECTION
ENGINE = "love"
ENGINE_PATH = "engines." .. ENGINE .. "."

EngineInit = LuaExt.TryRequire(ENGINE_PATH .. "Init")
EngineControl = LuaExt.TryRequire(ENGINE_PATH .. "Control")
EngineEvent = LuaExt.TryRequire(ENGINE_PATH ..  "Event")
EngineRead = LuaExt.TryRequire(ENGINE_PATH .. "Read")

-- GAME SPECIFIC ENGINE INIT (if exists)
GAME_ENGINE_PATH = GAME_PATH .. ENGINE_PATH .. "Init"

GameEngineInit = LuaExt.TryRequire(GAME_ENGINE_PATH)

-- ================================================================ --
-- ================================================================ --
-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal

--[[
print(_VERSION)
if math.type then print(math.type(3)) end
if love then print(love.getVersion()) end
]]--
