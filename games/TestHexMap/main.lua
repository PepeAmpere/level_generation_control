print("TestGameScreen")

FPS_SIM = 10 -- frames per second for simulation

Components = require("libs.sim.Components")
Entity = require("libs.sim.Entity")
EntityTypes = require(GAME_PATH .. "data.entityTypes")

HexTypesDefs = require(GAME_PATH .. "data.hexTypes")
HexTreeTilesDefs = require(GAME_PATH .. "data.hexTreeTiles")

HexBase = require("libs.map.HexBase")
HexMap = require("libs.map.HexMap")
HexTurtle = require("libs.map.HexTurtle")

Systems = require("libs.sim.Systems")

Simulation = require("libs.sim.Simulation"); require("libs.sim.test.Simulation_test")
OneSim = Simulation.new(0, love.timer.getTime())

ScreenTypesDefs = require(GAME_PATH .. "data.screenTypes")

SavesStatus = Saves.new(GAME_PATH .. "data.saves")
local hasAnySaves = SavesStatus:HasAnySaves()

if hasAnySaves then

  -- levelMap = Simulation.load(LastSave)
  levelMap = require(GAME_PATH .. "newMapTemp")

else

  -- make new level if there is nothing to load
  levelMap = require(GAME_PATH .. "newMapTemp")

end