local nodesDefs = {
  ["Cabinet"] = { relativePosition = Vec3(-220, 420, 0), tags = {"is"} },
  ["EastEntrance"] = { relativePosition = Vec3(0, 420, 0), tags = {"tc", "east"} },
  ["PhotoWall"] = { relativePosition = Vec3(128, 0, 0) },
  ["RitualTable"] = { relativePosition = Vec3(88, 0, 0), tags = {"is"} },
  ["RoomCorner"] = { relativePosition = Vec3(60, -370, 0), tags = {"is"} },
  ["RoomEastDoor"] = { relativePosition = Vec3(0, 370, 0) },  
  ["RoomNextToCabinet"] = { relativePosition = Vec3(-220, 370, 0) },
  ["RoomNextToCorner"] = { relativePosition = Vec3(40, -240, 0) },
  ["RoomNextToRitualTable"] = { relativePosition = Vec3(60, 0, 0) },
  ["RoomSouthDoor"] = { relativePosition = Vec3(-370, 0, 0) },
  ["RoomStartPosition"] = { relativePosition = Vec3(-180, 0, 0), tags = {"sp"} },
  ["SouthEntrance"] = { relativePosition = Vec3(-420, 0, 0), tags = {"tc", "south"} },
}

local edgesDefs = {
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
      "RoomSouthDoor",
      "RoomStartPosition",
      "RoomNextToCorner",
      "RoomNextToRitualTable",
    },
  },
}

local drawDefs = {
  "x", "x", "x",
  "w", "w", "w",
  "w", "w", "w",
}

local restrictions = {
  north = 0,
  east = 2,
  south = 2,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}