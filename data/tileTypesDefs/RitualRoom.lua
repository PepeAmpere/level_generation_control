local nodesData = {
  ["Cabinet"] = { relativePosition = Vec3(-300, 300, 0), tags = {"is"} },
  ["EastEntrance"] = { relativePosition = Vec3(0, 400, 0), tags = {"tc"} },
  ["PhotoWall"] = { relativePosition = Vec3(100, 0, 0) },
  ["RitualTable"] = { relativePosition = Vec3(50, 0, 0), tags = {"is"} },
  ["RoomCorner"] = { relativePosition = Vec3(-50, -200, 0), tags = {"is"} },
  ["RoomEastDoor"] = { relativePosition = Vec3(0, 350, 0) },  
  ["RoomNextToCabinet"] = { relativePosition = Vec3(-300, 250, 0) },
  ["RoomNextToCorner"] = { relativePosition = Vec3(50, -350, 0) },
  ["RoomNextToRitualTable"] = { relativePosition = Vec3(0, 0, 0) },
  ["RoomSouthDoor"] = { relativePosition = Vec3(-350, 0, 0) },
  ["RoomStartPosition"] = { relativePosition = Vec3(-150, 0, 0), tags = {"sp"} },
  ["SouthEntrance"] = { relativePosition = Vec3(-400, 0, 0), tags = {"tc"} },
}

local edgesData = {
  { edgeType = "directional", tags = {"pp"}, from = "RoomNextToRitualTable", to = "RitualTable" },
  { edgeType = "directional", tags = {"pp"}, from = "RitualTable", to = "RoomNextToRitualTable" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomNextToRitualTable", to = "PhotoWall" },
  { edgeType = "directional", tags = {"pp"}, from = "PhotoWall", to = "RoomNextToRitualTable" },
  { edgeType = "directional", tags = {"pp"}, from = "SouthEntrance", to = "RoomSouthDoor" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomSouthDoor", to = "SouthEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "EastEntrance", to = "RoomEastDoor" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomEastDoor", to = "EastEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomNextToCabinet", to = "Cabinet" },
  { edgeType = "directional", tags = {"pp"}, from = "Cabinet", to = "RoomNextToCabinet" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomNextToCorner", to = "RoomCorner" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomCorner", to = "RoomNextToCorner" },
  { edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "RoomEastDoor",
      "RoomNextToCabinet",
      "RoomNextToCorner",
      "RoomNextToRitualTable",
      "RoomSouthDoor",
      "RoomStartPosition",
    },
  },
}

local drawData = {
    "x", "x", "x",
    "w", "w", "w",
    "w", "w", "w",
}

return {
  nodesData = nodesData,
  edgesData = edgesData,
  drawData = drawData,
}