-- globalize the libs (to integrate both in replit, love 2D and also Unreal)
-- libs

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

UnrealEvent = require("libs.unreal.UnrealEvent")

GAME = "TheDarkShift"
GAME_PATH = "games." .. GAME .. "."

require(GAME_PATH .. "main") -- main.lua of the game

-- ================================================================ --
-- ================================================================ --
-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal

--[[
print(_VERSION)
if math.type then print(math.type(3)) end
if love then print(love.getVersion()) end
]]--