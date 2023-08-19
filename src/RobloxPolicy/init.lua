-- Roblox Policy
-- Mia Vince
-- November 02, 2022

local assert = assert

local EUROPE_COUNTRY_CODES = {
	"GB",
	"CH",
	"SE",
	"ES",
	"SI",
	"SK",
	"GR",
	"RO",
	"AT",
	"PT",
	"PL",
	"NO",
	"NL",
	"DE",
	"MT",
	"HU",
	"LU",
	"LV",
	"LT",
	"LI",
	"CY",
	"IT",
	"IS",
	"IE",
	"HR",
	"FR",
	"FI",
	"EE",
	"DK",
	"CZ",
	"BG",
	"BE",
}

local LocalizationService = game:GetService("LocalizationService")
local PolicyService = game:GetService("PolicyService")

local Packages = script.Parent
local Promise = require(Packages.Promise)
local t = require(Packages.t)

--[=[
    @class RobloxPolicy
    A quick handler for validating certain Roblox policies.
]=]
local RobloxPolicy = {}

--[=[
    @param player Player
    @return Promise
    Checks if the player is in Europe.
]=]
function RobloxPolicy.isEurope(player: Player)
	assert(t.any(player))
	return Promise.new(function(resolve)
		local code = LocalizationService:GetCountryRegionForPlayerAsync(player)
		resolve(table.find(EUROPE_COUNTRY_CODES, code) ~= nil)
	end)
end

--[=[
    @param player Player
    @return Promise
    Checks if the player is subject to China policies.
]=]
function RobloxPolicy.isSubjectToChinaPolicies(player: Player)
	assert(t.any(player))
	return Promise.new(function(resolve)
		local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(player)
		resolve(policyInfo.IsSubjectToChinaPolicies)
	end)
end

--[=[
    @param player Player
    @param link string
    @return Promise
    Checks if the "link" is allowed.
]=]
function RobloxPolicy.isExternalLinkAllowed(player: Player, link: string)
	assert(t.any(player))
	assert(t.string(link))
	return Promise.new(function(resolve)
		local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(player)
		resolve(table.find(policyInfo.AllowedExternalLinkReferences, link) ~= nil)
	end)
end

--[=[
    @param player Player
    @return Promise
    Checks if the player can trade paid items.
]=]
function RobloxPolicy.isPaidItemTradingAllowed(player: Player)
	assert(t.any(player))
	return Promise.new(function(resolve)
		local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(player)
		resolve(policyInfo.IsPaidItemTradingAllowed)
	end)
end

--[=[
    @param player Player
    @return Promise
    Checks if paid random items are restricted for the player.
]=]
function RobloxPolicy.arePaidRandomItemsRestricted(player: Player)
	assert(t.any(player))
	return Promise.new(function(resolve)
		local policyInfo = PolicyService:GetPolicyInfoForPlayerAsync(player)
		resolve(policyInfo.ArePaidRandomItemsRestricted)
	end)
end

return RobloxPolicy
