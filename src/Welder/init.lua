-- Welder
-- Mia Vince
-- October 22, 2022

local t = require(script.Parent.t)

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
	@param container Model?
	@param root BasePart?
	@return Welder
	Constructs a Welder, used for welding instances to a root instance.
]=]
function Welder.new(container: Model?, root: BasePart?)
	local self = setmetatable({
		Destroyed = false,
		BindList = {},
	}, Welder)

	if container and root then
		self:Bind(container, root or container.PrimaryPart)
	end

	return self
end

--[=[
	@param container Model
	@param weldTo BasePart
	Prepares the `container` for welding to `weldTo`.

	:::caution
	Run this before calling `Welder:Apply()
	:::
]=]
function Welder:Bind(container: Model, weldTo: BasePart)
	assert(t.any(container))
	assert(t.any(weldTo))

	if self.Destroyed then
		return
	end

	self.Instance = container
	self.PrimaryPart = weldTo or container.PrimaryPart
	table.clear(self.BindList)

	-- Cache
	local primaryPart = self.PrimaryPart
	for _, v in container:GetDescendants() do
		if not v:IsA(`BasePart`) then
			continue
		end
		if v == weldTo then
			continue
		end
		table.insert(self.BindList, {
			primaryPart,
			v,
			primaryPart.CFrame:ToObjectSpace(v.CFrame),
		})
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
function Welder:Apply(applyAsMotor: boolean?)
	if self.Destroyed then
		return
	end

	local bindList = self.BindList
	if #bindList == 0 then
		return
	end

	-- Folder
	local basePrimaryPart = self.PrimaryPart
	local welds = basePrimaryPart:FindFirstChild(`Welds`) :: Folder
	if not welds then
		welds = Instance.new(`Folder`)
		welds.Name = `Welds`
		welds.Parent = basePrimaryPart
	end

	welds:ClearAllChildren()

	-- Bind
	local className = if applyAsMotor then `Motor6D` else `Weld`
	for _, bind in bindList do
		local primaryPart, part, offset = unpack(bind)
		local joint = Instance.new(className)
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

	local welds = self.PrimaryPart:FindFirstChild(`Welds`)
	if not welds then
		return
	end
	welds:Destroy()
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

	-- Break
	if breakJoints then
		self:Break()
	end

	-- Clean
	self.BindList = nil
	self.Model = nil
	self.PrimaryPart = nil
end

export type Welder = typeof(Welder.new(...))
return Welder
