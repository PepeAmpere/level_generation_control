local type = type
local sqrt3 = math.sqrt(3)
local sqrt3_half = sqrt3 / 2
local PI = math.pi
local sin = math.sin
local cos = math.cos

local hexIndex = {}
local hexMeta = {}
hexMeta.__index = hexIndex

local function new(q, r, s, size)
  return setmetatable(
    {
      q = q or 0,
      r = r or 0,
      s = s or 0,
      size = size or 1,
      -- size = grid size
      -- scale = visual size of one hex
    },
    hexMeta
  )
end

local function isHex3(hex)
  return type(hex) == "table" and
      type(hex.q) == "number" and
      type(hex.r) == "number" and
      type(hex.s) == "number" and
      hex.q + hex.r + hex.s == 0
end

local Hex3 = new

-- operators
function hexMeta:__add(hex)
  return new(
    self.q + hex.q,
    self.r + hex.r,
    self.s + hex.s
  )
end

function hexMeta:__sub(hex)
  return new(
    self.q - hex.q,
    self.r - hex.r,
    self.s - hex.s
  )
end

function hexMeta:__mul(hex)
  if (type(hex) == "number") then
    return new(
      self.q * hex,
      self.r * hex,
      self.s * hex
    )
  else
    return new(
      self.q * hex.q,
      self.r * hex.r,
      self.s * hex.s
    )
  end
end

function hexMeta:__div(hex)
  if (type(hex) == "number") then
    return new(
      self.q / hex,
      self.r / hex,
      self.s / hex
    )
  else
    return new(
      self.q / hex.q,
      self.r / hex.r,
      self.s / hex.s
    )
  end
end

function hexMeta:__eq(hex)
  return self.q == hex.q and self.r == hex.r and self.s == hex.s
end

function hexMeta:__unm()
  return new(
    -self.q,
    -self.r,
    -self.s
  )
end

function hexMeta:__tostring()
  return "Hex3(" .. self.q .. "," .. self.r .. "," .. self.s .. ")"
end

function hexMeta:__concat()
  return "Hex3(" .. self.q .. "," .. self.r .. "," .. self.s .. ")"
end

function hexIndex:ToKey(separator)
  if separator == nil then separator = "_" end
  return self.q .. separator .. self.r .. separator .. self.s
end

function hexIndex:Add(hex)
  self = self + hex
  return self -- copy
end

function hexIndex:Sub(hex)
  self = self - hex
  return self -- copy
end

function hexIndex:Mul(multiplier)
  self.q = self.q * multiplier
  self.r = self.r * multiplier
  self.s = self.s * multiplier
  return self -- copy(?)
end

function hexIndex:Q()
  return self.q
end

function hexIndex:R()
  return self.r
end

function hexIndex:S()
  return self.s
end

function hexIndex:ToPixel()
  return self.size * (sqrt3 * self.q + sqrt3_half * self.r),
      self.size * (1.5 * self.r)
end

local function PointCorner(x, y, size, i)
  local angle_deg = 60 * i - 30
  local angle_rad = PI / 180 * angle_deg
  return x + size * cos(angle_rad),
      y + size * sin(angle_rad)
end

function hexIndex:ToCorners(cornerDistance)
  local xBase, yBase = self:ToPixel()
  local points = {}
  for i = 1, 6 do
    local x, y = PointCorner(xBase, yBase, cornerDistance, i)
    points[#points + 1] = x
    points[#points + 1] = y
  end
  return points
end

function hexIndex:RotateRight()
  return new(
    -self.r,
    -self.s,
    -self.q
  )
end

function hexIndex:RotateLeft()
  return new(
    -self.s,
    -self.q,
    -self.r
  )
end

local DIRECTIONS = {
  { 1,  -1, 0 },
  { 1,  0,  -1 },
  { 0,  1,  -1 },
  { -1, 1,  0 },
  { -1, 0,  1 },
  { 0,  -1, 1 }
}

function hexIndex:Neighbor(directionIndex, distance)
  distance = distance or 1
  local d = DIRECTIONS[directionIndex]
  return new(
    self.q + d[1] * distance,
    self.r + d[2] * distance,
    self.s + d[3] * distance
  )
end

local DIAGONALS = {
  { 2,  -1, -1 },
  { 1,  1,  -2 },
  { -1, 2,  -1 },
  { -2, 1,  1 },
  { -1, -1, 2 },
  { 1,  -2, 1 }
}

function hexIndex:NeighborDiagonal(directionIndex)
  distance = distance or 1
  local d = DIAGONALS[directionIndex]
  return new(
    self.q + d[1] * distance,
    self.r + d[2] * distance,
    self.s + d[3] * distance
  )
end

function hexIndex:Length() -- should be multiplied by self.size, but defult is 1
  return self:LengthSQ() ^ 0.5
end

function hexIndex:LengthSQ()
  return ((self.q * self.q) + (self.r * self.r) + (self.s * self.s))
end

function hexIndex:Distance(hex)
  return (self - hex):Length()
end

function hexIndex:DistanceSQ(hex)
  return (self - hex):LengthSQ()
end

return Hex3
