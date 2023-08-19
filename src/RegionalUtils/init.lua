-- Regional Utils
-- Mia Vince
-- December 12, 2022

local ENDPOINT = "http://ip-api.com/json/"
local DUMMY_DATA = { city = "Playtest", regionName = game.Name, countryCode = "Studio", query = "0.0.0.0/0" }

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Packages = script.Parent
local Promise = require(Packages.Promise)

local IsStudio = RunService:IsStudio()

--[=[
	@class RegionalUtils
	Utilities for fetching geolocations.
]=]
local RegionalUtils = {}

--[=[
	@param fmt string?
	@param safe boolean?
	@return Promise
	Returns the server location data. If formatting is supplied, this function will return a string instead.
	Will also fetch your real location info if ran in studio and `safe` is off or nil.

	Example usage from project East:
	```lua
	RegionalUtils.getLocation("{city}, {regionName}, {countryCode}|{query}", true)
		:andThen(function(serverAddress: string)
			ReplicatedStorage:SetAttribute("Location", serverAddress)
		end)
		:catch(Output.warn)
	```
]=]
function RegionalUtils.getLocation(fmt: string?, safe: boolean)
	return Promise.new(function(resolve)
		local data = if IsStudio and safe then DUMMY_DATA else HttpService:JSONDecode(HttpService:GetAsync(ENDPOINT))
		if fmt then
			for k, v in data do
				fmt = fmt:gsub(`\{{k}\}`, v)
			end
			resolve(fmt)
		else
			resolve(data)
		end
	end)
end

return RegionalUtils
