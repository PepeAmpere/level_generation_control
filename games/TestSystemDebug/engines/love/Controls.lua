INIT_FLOOR = 1
INIT_COLUMN = 2
CURRENT_SCREEN = Vec3(INIT_FLOOR, INIT_COLUMN, 0)
LASTKEY = ""
WIDGET_HW = 100
RECT_W = 18
RECT_WO = 20

playerScreenMap = {
  { "empty", "intro", "empty" },
}
function GetScreenTypeName(position)
  local floor = position:X()
  local column = position:Y()
  return playerScreenMap[floor][column]
end

local function DrawCustomGrid(widget, windowName, tex, held, hovered, mx, my, values)
  local w,h = UI2D.GetWindowPosition(windowName)
  local y = widget.height/2
  local y2 = widget.height/4

  local col = { 0, 0, 0 }
  love.graphics.setCanvas(tex)
  love.graphics.clear(col)
  love.graphics.setColor(1, 1, 1)

  line = 0
  column = 0
  for i = 1, values.current - values.min do
    local yy = column*RECT_WO + 1
    love.graphics.setColor(0.8, 0.2, 0)
    love.graphics.rectangle("fill", yy, line*RECT_WO + 1, RECT_W, RECT_W)

    column = column + 1
    if column == 5 then
      column = 0
      line = line + 1
    end
  end
end

ElementsDrawFns = {
  AllEdges = function()
    local edges = SIMPLE_EDGES
    for _, edge in ipairs(edges) do
      ElementsDrawFns.OneEdge(edge)
    end
  end,
  AllEdgesLines = function()
    local edges = SIMPLE_EDGES
    for _, edge in ipairs(edges) do
      ElementsDrawFns.OneEdgeLine(edge)
    end
  end,
  AllNodes = function()
    local nodes = SIMPLE_NODES
    for _, node in ipairs(nodes) do
      ElementsDrawFns.OneNode(node)
    end
  end,
  None = function()
    UI2D.Begin("None ", 400, 0)
    UI2D.Label("This is empty page")
    UI2D.End()
  end,
  OneNode = function(node)
    local x, y = node.position:X(), node.position:Y()
    local values = node.values

    UI2D.Begin(node.name, x, y)
    UI2D.Label(values.min .. " [ " .. values.current .. " ] " .. values.max)
    local value, released = UI2D.SliderInt("",
      values.current,
      values.min,
      values.max,
      math.max(values.max, 100)
    )
    -- ! we need to instanciate the window to make possible end edit value check
    values.current = value

    local windowName = node.name
    local widget = {
      name = "widget_".. node.name,
      width = RECT_WO * 5,
      height = ((values.max - values.min) / 5) * RECT_WO + 1,
    }
    local ps, _, held, _, hovered, mx, my, _, _ = UI2D.CustomWidget(
      widget.name,
      widget.width, widget.height
    )
    DrawCustomGrid(widget, windowName, ps, held, hovered, mx, my, values )

    UI2D.End()
  end,
  OneEdge = function(edge)
    local startNode = SIMPLE_NODES[edge.startNodeIndex] -- temporary reference
    local endNode = SIMPLE_NODES[edge.endNodeIndex] -- temporary reference

    local sx, sy = UI2D.GetWindowPosition(startNode.name)
    local ex, ey = UI2D.GetWindowPosition(endNode.name)

    local newX, newY = math.floor((sx+ex)/2), math.floor((sy+ey)/2)

    UI2D.Begin(edge.name, newX, newY)

    -- ! we need to instanciate the window to make possible end edit value check
    local textBoxVal, finished_editing = UI2D.TextBox(
      "kkdh", 
      11, 
      edge.values.input1
    )
    edge.values.input1 = textBoxVal
    if textBoxVal ~= "" then
      edge.values.input1value = tonumber(textBoxVal or 1)
    end

    -- name, visibile rows, visible chars, list
    local clicked, idx = UI2D.ListBox( "list1", 4, 10, LIST_OF_FUNCTIONS )
    if clicked then edge.values.functionType = idx end
    
    UI2D.End()
  end,
  OneEdgeLine = function(edge)
    local startNode = SIMPLE_NODES[edge.startNodeIndex] -- temporary reference
    local endNode = SIMPLE_NODES[edge.endNodeIndex] -- temporary reference

    local sx, sy = UI2D.GetWindowPosition(startNode.name)
    local ex, ey = UI2D.GetWindowPosition(endNode.name)

    if sx then
        love.graphics.setColor(1, 1, 0.1)
        love.graphics.line(sx, sy, ex or 0, ey or 0)
        local newX, newY = math.floor((sx+ex)/2), math.floor((sy+ey)/2)
        UI2D.SetWindowPosition(edge.name, newX, newY)
    end

  end,
  SimPlay = function()
    UI2D.Begin("SimPlay", 200, 0)
    if UI2D.ToggleButton( "AutoPlay", toggle1 ) then
      toggle1 = not toggle1
      AUTOPLAY = toggle1
    end
    UI2D.End()
  end,
  SimStep = function()
    UI2D.Begin("SimStep", 0, 0)
    UI2D.Label("Step: " .. OneSim:GetStep())
    if UI2D.Button("Play step" ) then
      OneSim:Update(1)
      -- disconnected eval of transfers
      SimulateAllTransfers()
    end
    UI2D.End()
  end,
}
screenTypes = {
  empty = {
    DrawFn = function()
      ElementsDrawFns.None()
    end,
  },
  intro = {
    DrawFn = function()
      -- lines have to go prior everything else 
      -- (not just order, also other functions are limiting the context)
      ElementsDrawFns.AllEdgesLines()
      ElementsDrawFns.AllNodes()
      ElementsDrawFns.AllEdges()
      ElementsDrawFns.SimStep()
      ElementsDrawFns.SimPlay()
    end,
  },
}

local MIN_FLOOR = 1
local MIN_COLUMN = 1
local MAX_FLOOR = #playerScreenMap
local MAX_COLUMN = #playerScreenMap[MIN_COLUMN]
local directions = {
  up = Vec3(-1, 0, 0),
  down = Vec3(1, 0, 0),
  left = Vec3(0, -1, 0),
  right = Vec3(0, 1, 0),
}
function ScreenMove(direction)
  local newPosition = CURRENT_SCREEN + directions[direction]
  if newPosition:X() < MIN_FLOOR then return CURRENT_SCREEN end
  if newPosition:X() > MAX_FLOOR then return CURRENT_SCREEN end
  if newPosition:Y() < MIN_COLUMN then return CURRENT_SCREEN end
  if newPosition:Y() > MAX_COLUMN then return CURRENT_SCREEN end
  if screenTypes[GetScreenTypeName(newPosition)] then
    return newPosition
  else
    return CURRENT_SCREEN
  end
end