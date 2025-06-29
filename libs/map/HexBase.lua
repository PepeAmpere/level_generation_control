local DIRECTIONS = { -- clockwise
  "F", -- forward
  "R", -- right
  "S", -- sright
  "B", -- back
  "K", -- kleft
  "L", -- left
}

return {
  DIRECTIONS = DIRECTIONS,
  KeyToHex3 = function(key, separator)
    local _, _, q, r, s = string.find(
      key,
      "([+-]?%d+)" .. separator .. "([+-]?%d+)" .. separator .. "([+-]?%d+)"
    )
    return Hex3(q, r, s)
  end,
}