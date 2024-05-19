local nodesDefs = {

  -- door at the storage
  ["NEStorageEntrance"] = { relativePosition = Vec3(100, 250, 0) },
  ["NextNEStorageEntrance"] = { relativePosition = Vec3(50, 250, 0) },
  ["NWStorageEntrance"] = { relativePosition = Vec3(100, -250, 0) },
  ["NextNWStorageEntrance"] = { relativePosition = Vec3(50, -250, 0) },

  -- storage places
  ["NextStorage1"] = { relativePosition = Vec3(300, -200, 0) },
  ["NextStorage2"] = { relativePosition = Vec3(300, -75, 0) },
  ["NextStorage3"] = { relativePosition = Vec3(300, 50, 0) },
  ["NextStorage4"] = { relativePosition = Vec3(300, 175, 0) },
  ["Storage1"] = { relativePosition = Vec3(250, -200, 0), tags = {"is"} },
  ["Storage2"] = { relativePosition = Vec3(250, -75, 0), tags = {"is"} },
  ["Storage3"] = { relativePosition = Vec3(250, 50, 0), tags = {"is"} },
  ["Storage4"] = { relativePosition = Vec3(250, 175, 0), tags = {"is"} },

  -- doors and entrances
  ["RoomSouthDoor"] = { relativePosition = Vec3(-370, 0, 0) },
  ["RoomWestDoor"] = { relativePosition = Vec3(0, -370, 0) },
  ["SouthEntrance"] = { relativePosition = Vec3(-420, 0, 0), tags = {"tc", "south"} },
  ["WestEntrance"] = { relativePosition = Vec3(0, -420, 0), tags = {"tc", "west"} },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "RoomSouthDoor", to = "SouthEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "SouthEntrance", to = "RoomSouthDoor" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomWestDoor", to = "WestEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "WestEntrance", to = "RoomWestDoor" },
  { edgeType = "directional", tags = {"pp"}, from = "NEStorageEntrance", to = "NextNEStorageEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "NextNEStorageEntrance", to = "NEStorageEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "NWStorageEntrance", to = "NextNWStorageEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "NextNWStorageEntrance", to = "NWStorageEntrance" },

  { edgeType = "directional", tags = {"pp"}, from = "NextStorage1", to = "Storage1" },
  { edgeType = "directional", tags = {"pp"}, from = "Storage1", to = "NextStorage1" },
  { edgeType = "directional", tags = {"pp"}, from = "NextStorage2", to = "Storage2" },
  { edgeType = "directional", tags = {"pp"}, from = "Storage2", to = "NextStorage2" },
  { edgeType = "directional", tags = {"pp"}, from = "NextStorage3", to = "Storage3" },
  { edgeType = "directional", tags = {"pp"}, from = "Storage3", to = "NextStorage3" },
  { edgeType = "directional", tags = {"pp"}, from = "NextStorage4", to = "Storage4" },
  { edgeType = "directional", tags = {"pp"}, from = "Storage4", to = "NextStorage4" },

  { edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "RoomSouthDoor",
      "RoomWestDoor",
      "NextNWStorageEntrance",
      "NextNEStorageEntrance",
    },
  },
  { edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "NWStorageEntrance",
      "NextStorage1",
      "NextStorage2",
      "NextStorage3",
      "NextStorage4",
      "NEStorageEntrance",
    },
  },
}

local drawDefs = {
  "w", "w", "w",
  "w", "w", "w",
  "w", "w", "w",
}

local restrictions = {
  north = 0,
  east = 0,
  south = 2,
  west = 2,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}