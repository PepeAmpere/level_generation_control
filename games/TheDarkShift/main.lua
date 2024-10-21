-- data
-- tile types defs tags and vectors are updated in Unreal on load of level from actual blueprints
tileTypesDefs = require(GAME_PATH .. "data.tileTypes")

-- layout types in data.layoutTypes are testing ones in Love2D, in unreal use defs in Unreal repo
local qResult = require(GAME_PATH .. "data.layoutTypes")
layoutTypes = qResult[1]
layoutTypesDefs = qResult[2]

-- unchanged, used by Love2D and Unreal without any difference
local pResult = require(GAME_PATH .. "data.productionRules")
productionRulesTypes = pResult[1]
productionRulesDefs = pResult[2]

-- prepare the level generation
math.randomseed( os.time() )
local MapMakingFunction = require ("libs.generator.layoutBasedGenerator")

-- run the level generation once
levelMap = MapMakingFunction(layoutTypesDefs.BlockedPath)

-- ================================================================ --
-- ================================================================ --
-- == UNREAL INTEGRATION WILL NEED ABOVE CODE in the Lua Wrapper == --
-- saved on this level to avoid saving in Unreal

-- simplified export
--[[
local exportTable = UnrealEvent.SaveMap()
local jsonString = JSON.encode(exportTable)
TableExt.SaveToFile("levelMapExported.lua", {json = jsonString})
TableExt.SaveToFile("levelMapExported.lua", exportTable)
]]--

FPS_SIM = 10 -- frames per second for simulation

Entity = require("libs.sim.Entity")
Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())