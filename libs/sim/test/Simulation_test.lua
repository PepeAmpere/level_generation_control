-- Test for Simulation.lua

-- A: actual
-- B: expected

local function Simulation_test()
    local SimA = Simulation.new(0, 0)
    local exportedData = SimA:Export()

    -- local testData = {
    --     entities = {},
    --     lastEntityIndex = 0,
    --     startTime = 0,
    --     step = 0,
    --     systems = {},
    --     t = 0,
    -- }
    local SimBLoaded = Simulation.load(exportedData)

    -- LU.assertEquals( exportedData, testData, "\nTest of Export" )
    LU.assertEquals( SimBLoaded, SimA, "\n" ..
      "Simulation: Empty sim - End-to-end test of Export => Load"
    )

    -- this is so far specific test for the EntityType.Person, not global, project specific
    local entityA = SimA:AddEntityOfType(
      EntityTypes.Person, {
        IDprefix = "person",
        position = Vec3(-10, 10, 0)
      }
    )

    local testComponentName = "Position"
    local componentA = entityA:GetComponent(testComponentName)
    local exportedComponentData = componentA:Export()
    local loadedComponent = Components[testComponentName].load(exportedComponentData)
    LU.assertEquals( loadedComponent, componentA, "\n" ..
      "Component: Export => Load"
    )

    local exportedEntityData = entityA:Export()
    local loadedEntity = Entity.load(exportedEntityData)
    LU.assertEquals( loadedEntity, entityA, "\n" ..
      "Entity: Export => Load"
    )

    local exportedData = SimA:Export()
    local LoadedSim = Simulation.load(exportedData)
    LU.assertEquals( LoadedSim, SimA , "\n" ..
      "Simulation: End-to-end test of Export => Load" ..
      "• with one entity"
    )

    local testSystemName = "HexMap"
    local testSystemA = SimA:AddSystem(
      testSystemName,
      {
        q = 0, r = 0, s = 0,
        rootNodeTags = {
          hex = true,
          hexTypeName = TableExt.GetRandomValue(HexTypesDefs).name,
          hexTreeTile = TableExt.GetRandomValue(HexTreeTilesDefs).name,
        },
      }
    )
    local exportedSystemData = testSystemA:Export()
    local loadedSystem = Systems[testSystemName].load(exportedSystemData)
    LU.assertEquals( loadedSystem, testSystemA , "\n" ..
      "System: Export => Load"
    )

    local exportedData = SimA:Export()
    local LoadedSim = Simulation.load(exportedData)
    LU.assertEquals( LoadedSim, SimA , "\n" ..
      "Simulation: End-to-end test of Export => Load" ..
      "• with one entity" ..
      "• with one system"
    )

end

-- Run the test
Simulation_test()
print("Simulation tested")