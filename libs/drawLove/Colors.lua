local MODULE_NAME = "Colors"
local ASSERT_PREFIX = "[" .. MODULE_NAME .. "] "

-- list of constants in R, G, B, A unpacked format which is useful for LOVE 2D SetColor function
return {
  PATH = function() return 0, 256, 0, 128 end,
}