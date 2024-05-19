local productionRulesTypes = {
  "BlueAddPuzzleRooms",
  "BlueBlocked",
  "BlueCandleRoom",
  "BlueExtend",
  "BlueExtendAroundCorridor",
  "InitialExit",
  "RitualRoomLoopZero",
  "UndefinedToCorridors",
  "YellowLeafLongCustomCorridor",
  "YellowShort",
  "YellowToBlue",
  "YellowToBlueBlocked",
}

local productionRulesDefs = {}
for _, prdouctionRuleName in ipairs(productionRulesTypes) do
  productionRulesDefs[prdouctionRuleName] = require(GAME_PATH .. "data.productionRulesDefs." .. prdouctionRuleName)
end

return { productionRulesTypes, productionRulesDefs }

--[[
-- NEW RULE TEMPLATE --
local function CustomSearchAndMatch(Matcher, Transformer, levelMap)

end

local function Matcher(tree, tile, levelMap)

end

local function Transformer(tree, tile, levelMap)

return {
  SearchAndTransform = SearchAndTransform,
  Matcher = Matcher,
  Transformer = Transformer,
}
]]
--
