print("Curvetica main")

FPS_SIM = 20 -- frames per second for simulation

Entity = require("libs.sim.Entity")
Simulation = require("libs.sim.Simulation")
OneSim = Simulation.New(0, love.timer.getTime())