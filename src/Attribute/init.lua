-- Attribute
-- Mia Fenneki
-- September 27, 2022

local DESTROYED_MESSAGE = "Attribute is destroyed"

local Signal = require(script.Signal)

local function GetAttributeNames(inst)
	local attributes = inst:GetAttributes()
	local names = {}
	for name in pairs(attributes) do
		table.insert(names, name)
	end

	return names
end

local function Watch(class, attribute)
	local instance = class.Instance
	local attributeChanged
	attributeChanged = instance:GetAttributeChangedSignal(attribute):Connect(function()
		local value = instance:GetAttribute(attribute)
		class.AttributeChanged:Fire(attribute, value or nil)

		-- Disconnect if the attribute was removed
		if not value then
			attributeChanged:Disconnect()
			attributeChanged = nil
		end
	end)
	class.Destroying:ConnectOnce(function()
		if attributeChanged then
			attributeChanged:Disconnect()
			attributeChanged = nil
		end
	end)
end

--[=[
    @class Attribute
    Attribute library.

    This is useful for tracking and updating attributes of an instance without the absurdly long `:GetAttribute` and `:SetAttribute` functions.
    An example Attribute may look like this:
    ```lua
    local Attribute = require(path.to.attribute)
    local Part = Instance.new("Part")
    local PartAttribute = Attribute.new(part)

    -- Setting an attribute:
    PartAttribute:Set("Name", 1234)

    -- Getting an attribute via method:
    local attribute = PartAttribute:Get("Name")

    -- Getting an attribute via reference:
    local attribute = PartAttribute.Name

    -- Listening for attribute changes:
    PartAttribute.AttributeChanged:Connect(function(attribute, value)
        print(attribute, value)
    end)

    -- Removing an attribute:
    PartAttribute:Remove("Name")

    print(PartAttribute:Get("Name")) -- nil
    print(PartAttribute.Name) -- nil

    -- Destroying the Attribute:
    PartAttribute:Destroy()

    -- Do note that if the instance is destroyed, the Attribute will also destroy.
    ```
]=]
local Attribute = {}
Attribute.__index = function(self, k)
	if self.Destroyed then
		error(DESTROYED_MESSAGE, 2)
	end

	local attributeNames = GetAttributeNames(self.Instance)
	if table.find(attributeNames, k) then
		return self.Instance:GetAttribute(k)
	elseif rawget(self, k) then
		return rawget(self, k)
	else
		return nil
	end
end
Attribute.__tostring = function(self)
	return "Attribute(" .. self.Instance.Name .. ")"
end

--[=[
    @param instance Instance
    @return Attribute
    Constructs an Attribute for the `instance`.
]=]
function Attribute.new(instance)
	local self = setmetatable({
		Instance = instance,
		Attributes = {},

		IsDestroyed = false,

		-- Signals
		AttributeChanged = Signal.new(),
		Destroying = Signal.new(),
	}, Attribute)

	for attribute in pairs(instance:GetAttributes()) do
		Watch(self, attribute)
	end

	local ancestryChanged
	ancestryChanged = instance.AncestryChanged:Connect(function(_, parent)
		if not parent then
			ancestryChanged:Disconnect()
			ancestryChanged = nil
			self:Destroy()
		end
	end)

	return self
end

--[=[
	@param attributeName string
	Removes an attribute.
]=]
function Attribute:Remove(attributeName)
	assert(not self.IsDestroyed, DESTROYED_MESSAGE)
	self.Instance:SetAttribute(attributeName, nil)
end

--[=[
	@param attributeName string
	@param value any
	Sets an attribute.
]=]
function Attribute:Set(attributeName, value)
	assert(not self.IsDestroyed, DESTROYED_MESSAGE)
	local attributeNames = GetAttributeNames(self.Instance)

	-- Bind changed listener if it doesnt exist already:
	if not table.find(attributeNames, attributeName) then
		Watch(self, attributeName)
	end

	-- Apply attribute:
	self.Instance:SetAttribute(attributeName, value)
end

--[=[
    @param attributeName string
    @return any
    Gets an attribute.

    :::tip
    You can also directly reference attributes by doing `Attribute.attributeName`.
    ```lua
    Attribute:Set("Test", true)
    print(Attribute.Test) -- true
    ```
    :::

    :::caution
    If the instance doesn't have the attribute you are trying to find, this function will return nothing.
    :::
]=]
function Attribute:Get(attributeName)
	local value = self.Instance:GetAttribute(attributeName)
	return value
end

--[=[
    Destroys the Attribute.
]=]
function Attribute:Destroy()
	self.Destroying:Fire()
	self.Destroying:Destroy()
	self.AttributeChanged:Destroy()

	self.IsDestroyed = true
end

export type Attribute = typeof(Attribute.new(Instance.new("Part")))
return Attribute
