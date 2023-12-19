local imagesList = {
  {name = "cross", ext = "png"},
  {name = "check", ext = "png"},
}

local images = {}
for i,v in ipairs(imagesList) do
  images[v.name] = love.graphics.newImage("data/images/" .. v.name .. "." .. v.ext)
end

return images