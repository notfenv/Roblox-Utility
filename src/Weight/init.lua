-- Weight
-- Mia Vince
-- August 19, 2023

--[=[
    @class Weight
    A weight chance system for selecting random items based on assigned weights
]=]
local Weight = {}
Weight.__index = Weight

--[[
    Constructs a new Weight object.
    @return Weight
]]
function Weight.new()
	local self = setmetatable({}, Weight)
	self.weights = {}
	self.totalWeight = 0
	return self
end

--[[
    @param item any
    @param weight number
    Adds an item with its corresponding weight.
]]
function Weight:add(item: any, weight: number)
	self.weights[item] = weight
	self.totalWeight += weight
end

--[[
    @param item any
    Removes an item.
]]
function Weight:remove(item: any)
	local weight = self.weights[item]
	if not weight then
		return
	end
	self.weights[item] = nil
	self.totalWeight -= weight
end

--[=[
    Chooses an item in the Weight.
    @return any
]=]
function Weight:choose()
	local randomValue = math.random() * self.totalWeight
	local currentWeight = 0

	for item, weight in self.weights do
		currentWeight += weight
		if randomValue <= currentWeight then
			return item
		end
	end

	return nil
end

return Weight
