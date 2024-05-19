local REAL_PATH = string.gsub(GAME_PATH, "%.", "%/")
local imagesList = {
  {name = "cross", ext = "png"},
  {name = "check", ext = "png"},
  {name = "plus", ext = "png"},
}

local images = {}
for i,v in ipairs(imagesList) do
  images[v.name] = love.graphics.newImage(REAL_PATH .. "data/images/" .. v.name .. "." .. v.ext)
end

return images