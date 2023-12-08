local nodesDefs = {
  ["EastEntrance"] = { relativePosition = Vec3(0, 400, 0), tags = {"tc"} },
  ["InFrontOfExit"] = { relativePosition = Vec3(0, 250, 0) },
  ["Exit"] = { relativePosition = Vec3(0, 50, 0), tags = {"exit"} },
}

local edgesDefs = {
  { edgeType = "directional", tags = {"pp"}, from = "EastEntrance", to = "InFrontOfExit" },
  { edgeType = "directional", tags = {"pp"}, from = "InFrontOfExit", to = "EastEntrance" },
  { edgeType = "directional", tags = {"pp"}, from = "InFrontOfExit", to = "Exit" },
}

local drawDefs = {
    "w", "w", "x",
    "w", "w", "w",
    "w", "w", "x",
}

return {
  nodesDefs = nodesDefs,
  edgesDefs = edgesDefs,
  drawDefs = drawDefs,
}