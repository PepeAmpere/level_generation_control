-- hardreferenced globals
-- UI_STATES
-- CENTER_X
-- ABOVE_NODE_Y

local function MakePartsVertices(x, y, model, scale)
  local partsVertices = {}
  for part, vertices in pairs(model) do
    partsVertices[part] = {}
    for i = 0, #vertices - 1 do
      partsVertices[part][2 * i + 1] = x + scale * vertices[i + 1]:X()
      partsVertices[part][2 * i + 2] = y + scale * vertices[i + 1]:Y()
    end
  end
  return partsVertices
end

local function RotateTemplate(template, angle)
  local angleSin, angleCos = math.sin(angle), math.cos(angle)

  local rotatedTemplate = {}
  for part, vertices in pairs(template) do
    rotatedTemplate[part] = {}
    for i = 1, #vertices do
      local newX = vertices[i]:X() * angleCos - vertices[i]:Y() * angleSin
      local newY = vertices[i]:X() * angleSin + vertices[i]:Y() * angleCos
      rotatedTemplate[part][i] = Vec3(newX, newY, 0)
    end
  end
  return rotatedTemplate
end

return {
  Coordinates = function(simPosition)
    local stringToWrite = tostring(simPosition)
    local x, y = simPosition:ToPixel()
    local drawCoords = Vec3(x, y, 0)
    if UI_STATES.textfields[stringToWrite] then
      local textColor = { 0.5, 1, 0.5, 1 }
      Draw.Text(
        UI_STATES.textfields[stringToWrite],
        drawCoords + Vec3(CENTER_X, ABOVE_NODE_Y, 0),
        textColor
      )
    else
      local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
      UI_STATES.textfields[stringToWrite] = text
    end
  end,

  DebugUIStates = function()
    local w, h = love.graphics.getDimensions()

    -- top left corner
    local halfTop = h/4
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("fill", 0, halfTop, 200, 65)
    love.graphics.setColor(0, 0, 0, 1)
    local counter = 0
    for k,v in pairs(UI_STATES) do
      love.graphics.print(tostring(k) .. ": " .. tostring(v), 0, halfTop + counter*10)
      counter = counter + 1
    end
  end,

  NodeSelected = function(selectedHexKey, scale)
    local selectedHexPosition = levelMap:GetAnyHexPosition(selectedHexKey, "_")
    local vertices = selectedHexPosition:ToCorners(scale * 0.9)
    local latestColor = { 0.7, 0.7, 0.7, 0.5 }
    love.graphics.setLineWidth(10)
    love.graphics.setLineStyle("rough")
    Draw.Polygon(
      vertices,
      latestColor,
      "line"
    )
    local counter = 0
    local basex, basey = selectedHexPosition:ToPixel()
    local selectedHex = levelMap:GetHexOnPosition(selectedHexKey)
    local hexTypeName
    if selectedHex then
      hexTypeName = selectedHex:GetTagValue("hexTypeName")
      local stringToWrite = tostring(hexTypeName)
      if UI_STATES.textfields[stringToWrite] then
        local textColor = { 0, 0, 0, 1 }
        Draw.Text(
          UI_STATES.textfields[stringToWrite],
          Vec3(basex-50, basey-25, 0),
          textColor
        )
      else
        local text = love.graphics.newText(love.graphics.getFont(), stringToWrite)
        UI_STATES.textfields[stringToWrite] = text
      end
    end
  end,

  NodeShape = function(node, scale)
    local hexCoords = node:GetPosition()
    local vertices = hexCoords:ToCorners(scale * 0.8)

    local latestColor = { 0.5, 1, 0.5, 0.5 }
    local hexTypeName
    if node:GetTagValue("hexTypeName") then
      hexTypeName = node:GetTagValue("hexTypeName")
      if HexTypesDefs[hexTypeName] then
        latestColor = HexTypesDefs[hexTypeName].drawDefs.color
      end
    end
    Draw.Polygon(
      vertices,
      latestColor
    )
  end,

  NodeTreeElements = function(node, scale)
    local hexCoords = node:GetPosition()
    local latestColor
    local hexTreeTileName
    if node:GetTagValue("hexTreeTile") then
      hexTreeTileName = node:GetTagValue("hexTreeTile")
      if HexTreeTilesDefs[hexTreeTileName] then
        latestColor = HexTreeTilesDefs[hexTreeTileName].drawDefs.color
      end
    end
    local basex, basey = hexCoords:ToPixel()
    local sideVertices = hexCoords:ToSidePoints(scale * 0.8)
    if hexTreeTileName and HexTreeTilesDefs[hexTreeTileName] then
      local drawTable = HexTreeTilesDefs[hexTreeTileName].drawDefs.drawTable
      if drawTable then
        for i=1, 6 do
          local character = drawTable[i]
          if character ~= "x" then
            if character == "O" then
              latestColor = { 1, 0.2, 0.2, 0.5 }
            else
              latestColor = { 0.8, 0.8, 0.2, 0.5 }
            end
            local secondx = sideVertices[(i-1)*2 + 1]
            local secondy = sideVertices[(i-1)*2 + 2]

            Draw.Line(
              Vec3(basex, basey, 0),
              Vec3(secondx, secondy, 0),
              2,
              latestColor
            )
          end
        end
      end
    end
  end,

  PersonAll = function(camera, sensorName, phase)
    local angle = camera:getAngle()
    local parts = {}
    local colors = {}

    for typeName, typeDef in pairs(EntityTypes) do
      if typeDef.LoveDraw[sensorName] then
        local partsTemplate, colorsTemplate = typeDef.LoveDraw[sensorName](phase)
        local rotatedTemplate = RotateTemplate(partsTemplate, angle)
        parts[typeName] = rotatedTemplate
        colors[typeName] = colorsTemplate
      end
    end

    local allEntities = OneSim:GetEntities()

    for entityID, entity in pairs(allEntities) do
      local scale = 5
      local position = entity:GetComponent("Position"):Get()
      local typeName = entity:GetTypeName()
      local rotatedTemplate = parts[typeName]
      local color = colors[typeName]
      if rotatedTemplate then

        local partsVertices = MakePartsVertices(
          position:X(),
          position:Y(),
          rotatedTemplate,
          scale
        )
        for part, vertices in pairs(partsVertices) do
          love.graphics.setColor(color[1], color[2], color[3], color[4])
          love.graphics.polygon("fill", vertices)
          --Draw.Polygon(
          --  vertices,
          --  latestColor
          --)
        end
      end
    end
  end,

  SensorsUI = function(camera, sensorName, phase)
    local w, h = love.graphics.getDimensions()
    local buttonSize = 80
    local buttonSizeHalf = buttonSize/2
    local paddingLeft = 5
    local centerX = w/2
    local marginLeft = centerX - (#SensorTypesDefs * buttonSizeHalf)
    local bottomBottonH = h - buttonSize
    for i,v in ipairs(SensorTypesDefs) do
      love.graphics.setColor(1, 1, 1, 0.8)
      if v.name == sensorName then love.graphics.setColor(0.8, 0.8, 0.8, 1) end
      love.graphics.rectangle(
        "fill",
        marginLeft + (i-1) * buttonSize,
        bottomBottonH,
        buttonSize,
        buttonSize
      )
      love.graphics.setColor(0, 0, 0, 1)
      love.graphics.print(
        tostring(v.name),
        marginLeft + paddingLeft + (i-1) * buttonSize,
        bottomBottonH + buttonSizeHalf
      )
    end
  end
}
