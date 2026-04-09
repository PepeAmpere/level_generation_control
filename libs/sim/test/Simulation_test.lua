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

    local q, r, s = 0, 0, 0
    local testSystemName = "HexMap"
    local testSystemA = SimA:AddSystem(
      testSystemName,
      {
        q = q, r = r, s = s,
        rootNodeTags = {
          hex = true,
          hexTypeName = TableExt.GetRandomValue(HexTypesDefs).name,
          hexTreeTile = TableExt.GetRandomValue(HexTreeTilesDefs).name,
        },
        scale = 10,
      }
    )
    local exportedSystemData = testSystemA:Export()
    local loadedSystem = Systems[testSystemName].load(exportedSystemData)
    LU.assertEquals( loadedSystem, testSystemA , "\n" ..
      "System: Export => Load"
    )

    local SimF = Simulation.new(0, 0)
    local testSystemF = SimF:AddSystem(
      testSystemName,
      {
        q = q, r = r, s = s,
        rootNodeTags = {
          hex = true,
          hexTypeName = "FictiveUndefType",
          hexTreeTile = TableExt.GetRandomValue(HexTreeTilesDefs).name,
        },
        scale = 10,
      }
    )
    local rootPosition = Hex3(q,r,s)
    local rootNodeID = rootPosition:ToKey()
    local exportedSystemFData = testSystemF:Export()
    local loadedSystemG = Systems[testSystemName].load(exportedSystemFData)
    LU.assertEquals(
      loadedSystemG.nodes[rootNodeID].tags.hexTypeName, 
      "FictiveUndefType" , "\n" ..
      "System: Export with legacy invalid types => Load with Undefined type"
    )
    LU.assertNotEquals(
      loadedSystemG.nodes[rootNodeID].tags.hexTypeName, 
      "UnsupportedLegacyType" , "\n" ..
      "System: Export with legacy invalid types => Load with Undefined type"
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