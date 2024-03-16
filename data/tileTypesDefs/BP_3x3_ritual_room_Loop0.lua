local nodesDefs = {
  ["RitualTable"] = { relativePosition = Vec3(88, 0, 0), tags = {"is"} },
  ["RoomNextToRitualTable"] = { relativePosition = Vec3(60, 0, 0) },
  ["RoomSouthDoor"] = { relativePosition = Vec3(-370, 0, 0) },
  ["RoomStartPosition"] = { relativePosition = Vec3(-180, 0, 0), tags = {"sp"} },
  ["SouthEntrance"] = { relativePosition = Vec3(-420, 0, 0), tags = {"tc", "south"} },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "RoomNextToRitualTable", to = "RitualTable" },
  { edgeType = "directional", tags = {"pp"}, from = "RitualTable", to = "RoomNextToRitualTable" },
  { edgeType = "directional", tags = {"pp"}, from = "SouthEntrance", to = "RoomSouthDoor" },
  { edgeType = "directional", tags = {"pp"}, from = "RoomSouthDoor", to = "SouthEntrance" },
  { edgeType = "multiedge", tags = {"pp"},
    nodes = {
      "RoomSouthDoor",
      "RoomStartPosition",
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
  east = 0,
  south = 2,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}