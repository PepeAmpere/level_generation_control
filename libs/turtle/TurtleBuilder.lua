-- autohor: PepeAmpere 2024-02

local TurtleBuilder = {}

local turtleFunctions = {
  ["1"] = function(turtle, positions, positionsIndex)
    turtle:forward(300)
    return positions, positionsIndex
  end,
  ["0"] = function(turtle, positions, positionsIndex)
    turtle:forward(300)
    return positions, positionsIndex
  end,
  ["["] = function(turtle, positions, positionsIndex)
    local x = turtle:xcor()
    local y = turtle:ycor()
    positionsIndex = positionsIndex + 1
    --print(turtle:xcor(), turtle:ycor(), math.deg(turtle:heading()))
    positions[positionsIndex] = {x = x, y = y, heading = math.deg(turtle:heading())}
    turtle:left(45)
    return positions, positionsIndex
  end,
  ["]"] = function(turtle, positions, positionsIndex)
    local posData = positions[positionsIndex]
    positionsIndex = positionsIndex - 1
    turtle:penup()
    turtle:setx(posData.x)
    turtle:sety(posData.y)
    turtle:pendown()
    turtle:setheading(posData.heading)
    --print(turtle:xcor(), turtle:ycor(), math.deg(turtle:heading()))
    turtle:right(45)
    return positions, positionsIndex
  end,
}

TurtleBuilder.Encode = function(turtle, turtleString)
  local turtleString = turtleString or ""

  local stringLength = string.len(turtleString)
  local positions = {}
  local positionsIndex = 0
  for i=1, stringLength do
    local char = turtleString:sub(i, i)
    positions, positionsIndex = turtleFunctions[char](turtle, positions, positionsIndex)
  end

  return turtle
end

return TurtleBuilder