-- Welder
-- Mia Fenneki
-- May 24, 2022

--[=[
	@class Welder
	A Welder is useful for welding objects together automatically.

	An example Welder may look like this:

	```lua
	local Welder = require(path.to.Welder)
	local Model = workspace.Model
	local welder = Welder.new()
	welder:Bind(Model, Model.PrimaryPart) -- Make data so the Welder knows what to weld, in this case we're welding all of the Model's children to it's PrimaryPart
	welder:Apply(true) -- Applying the welds as a Motor6D, this should create a Welds folder in the PrimaryPart with the welds in it
	task.wait(5)
	welder:Destroy(true) -- Destroy the welder while breaking the welds along with it
	```
]=]
local Welder = {}
Welder.__index = Welder

--[=[
	@param part Instance?
	@param root Instance?
	@return Welder
	Constructs a Welder, used for welding instances to a root instance.
]=]
function Welder.new(part, root)
	local self = setmetatable({
		Destroyed = false,
		BindList = {},
	}, Welder)

	if part and root then
		self:Bind(part, root or part.PrimaryPart)
	end

	return self
end

--[=[
	@param inst Instance
	@param weldTo Instance
	Prepares the `inst` for welding to `weldTo`.

	:::caution
	This function will go through the children of `inst`, not weld `inst` to `weldTo`.

	Run this before calling `Welder:Apply()`
	:::
]=]
function Welder:Bind(inst, weldTo)
	if self.Destroyed then
		return
	end

	self.Instance = inst
	self.PrimaryPart = weldTo or inst.PrimaryPart
	self.BindList = {}

	-- Cache:
	for _, v in ipairs(self.Instance:GetChildren()) do
		if v:IsA("BasePart") and v ~= weldTo then
			table.insert(self.BindList, {
				self.PrimaryPart,
				v,
				self.PrimaryPart.CFrame:ToObjectSpace(v.CFrame),
			})
		end
	end
end

--[=[
	@param applyAsMotor boolean | false
	Welds the model to the primary part, using a `Motor6D` if `applyAsMotor` is true.

	```lua
	local welder = Welder.new()
	welder:Bind(tool, tool.Handle)
	welder:Apply(true) -- All joints will be a Motor6D
	```
]=]
function Welder:Apply(applyAsMotor)
	if self.Destroyed then
		return
	end
	if #self.BindList == 0 then
		return
	end

	-- Folder:
	local welds = self.PrimaryPart:FindFirstChild("Welds")
	if not welds then
		welds = Instance.new("Folder")
		welds.Name = "Welds"
		welds.Parent = self.PrimaryPart
	end

	welds:ClearAllChildren()

	-- Bind:
	local class = if applyAsMotor then "Motor6D" else "Weld"
	for _, bind in ipairs(self.BindList) do
		local primaryPart, part, offset = table.unpack(bind)
		local joint = Instance.new(class)
		joint.Name = part.Name
		joint.Part0 = primaryPart
		joint.Part1 = part
		joint.C0 = offset

		joint.Parent = welds
	end
end

--[=[
	Destroys the welds.
]=]
function Welder:Break()
	if self.Destroyed then
		return
	end

	local welds = self.PrimaryPart:FindFirstChild("Welds")
	if welds then
		welds:Destroy()
	end
end

--[=[
	@param breakJoints boolean | false
	Destroys the Welder, and breaking the joints if `breakJoints` is true.
]=]
function Welder:Destroy(breakJoints)
	if self.Destroyed then
		return
	end

	self.Destroyed = true

	-- Break:
	if breakJoints then
		self:Break()
	end

	-- Clean:
	self.BindList = nil
	self.Model = nil
	self.PrimaryPart = nil
end

export type Welder = typeof(Welder.new())
return Welder
