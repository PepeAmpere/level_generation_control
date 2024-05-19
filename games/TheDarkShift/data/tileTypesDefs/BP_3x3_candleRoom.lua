local nodesDefs = {
  ["SouthEntrance"] = { relativePosition = Vec3(-420, 0, 0), tags = {"tc", "south"} },
  ["KeyLocation"] = { relativePosition = Vec3(190, 320, 60), tags = {"tc"}}
}

local edgesDefs = {
}

local drawDefs = {
  "w", "w", "x",
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