local nodesDefs = {
  ["EastEntrance"] = { relativePosition = Vec3(0, 420, 0), tags = {"tc", "east"} },
  ["InFrontOfExit"] = { relativePosition = Vec3(0, 250, 0) },
  ["Exit"] = { relativePosition = Vec3(0, 50, 0), tags = {"exit"} },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "EastEntrance", to = "InFrontOfExit" },
  { edgeType = "directional", tags = {"pp"}, from = "InFrontOfExit", to = "EastEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "InFrontOfExit", to = "Exit" },
}

local drawDefs = {
  "w", "x", "x",
  "x", "w", "w",
  "w", "x", "x",
}

local restrictions = {
  north = 0,
  east = 2,
  south = 0,
  west = 0,
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
  restrictions = restrictions,
}