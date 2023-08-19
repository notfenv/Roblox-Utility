local CFrame, math, typeof, Vector3, Color3, bit32, game = CFrame, math, typeof, Vector3, Color3, bit32, game

local RunService = game:GetService(`RunService`)

--[=[
	@class Math
	Math utilities.
	Used in project East.
]=]
local Math = {}

--[=[
	@prop epsilon number
	@within Math
]=]
Math.epsilon = (2 ^ -52)

--[=[
	@param t number
	@param dt number
	@return number
	Calculates the frame delta given the time elapsed (t) and delta time (dt)
]=]
function Math.frameDelta(t: number, dt: number): number
	return (1 - (1 - t) ^ (dt * 60))
end

--[=[
	@param value number
	@param roundingValue number
	@return number
	Rounds a value to the nearest multiple of `roundingValue`
]=]
function Math.round(value: number, roundingValue: number): number
	if roundingValue == 0 then
		return value
	end
	local result = value / roundingValue + 0.5
	if result % 1 == 0 then
		return result * roundingValue
	else
		return (result - (result % 1)) * roundingValue
	end
end

--[=[
	@param from number
	@param to number
	@param t number
	@return number
	Smoothly interpolates between two numbers (from and to) using a smooth curve.
]=]
function Math.smoothLerp(from: number, to: number, t: number): number
	local alpha = ((1 - math.cos(t * math.pi)) / 2)
	return if t < 0.001 then from else (if t > 0.999 then to else Math.lerp(from, to, alpha))
end

--[=[
	@param start Vector3
	@param to Vector3
	@param t number
	@return Vector3
	Interpolates between two vectors (`start` and `to`) using spherical linear interpolation.
]=]
function Math.slerpVector(start: Vector3, to: Vector3, t: number): Vector3
	local startVec = CFrame.lookAt(Vector3.zero, start)
	local endVec = CFrame.lookAt(Vector3.zero, to)
	local cf = startVec:Lerp(endVec, t)
	return cf.LookVector
end

--[=[
	@param from number|Color3
	@param to number|Color3
	@param t number
	@return number|Color3
	Safely interpolates between two numbers or colors (`from` and `to`) using linear interpolation.
]=]
function Math.safeLerp(from: number | Color3, to: number | Color3, t: number): number | Color3
	if not from or t >= 0.999 then
		return to
	elseif not to or t <= 0.001 then
		return from
	elseif typeof(from) == `Color3` then
		return Math.lerpColor3(from :: Color3, to :: Color3, t)
	elseif typeof(from) == `number` then
		return (from :: number * (1 - t) + to :: number * t)
	end
	return 0
end

--[=[
	@param random Random
	@param to Vector3
	@param t number
	@return Vector3
	Randomly generates a vector based on a direction (`to`) and a randomizer (`random`).
]=]
function Math.randomizeVector(random: Random, to: Vector3, t: number): Vector3
	local cframe = CFrame.new(Vector3.zero, to)
		* CFrame.Angles(0, 0, random:NextNumber(0, math.pi * 2))
		* CFrame.Angles(math.acos(random:NextNumber(math.cos(t), 1)), 0, 0)
	return cframe.LookVector * to.Magnitude
end

--[=[
	@param start CFrame
	@param to CFrame
	@param t number
	@return CFrame
	Interpolates between two CFrame objects (`start` and `to`) using linear interpolation.
]=]
function Math.interpolateCFrame(start: CFrame, to: CFrame, t: number): CFrame
	return if t < 0.001 then start else (if t > 0.999 then to else start:Lerp(to, t))
end

--[=[
	@param from Color3
	@param to Color3
	@param t number
	@return Color3
	Interpolates between two colors (`from` and `to`) using linear interpolation.
]=]
function Math.lerpColor3(from: Color3, to: Color3, t: number): Color3
	local inverse = (1 - t)
	local red = (from.R ^ 2 * inverse + to.R ^ 2 * t) ^ 0.5
	local green = (from.G ^ 2 * inverse + to.G ^ 2 * t) ^ 0.5
	local blue = (from.B ^ 2 * inverse + to.B ^ 2 * t) ^ 0.5
	return Color3.new(red, green, blue)
end

--[=[
	@param from number
	@param to number
	@param t number
	@return number
	Interpolates between two numbers (`from` and `to`) using linear interpolation.
]=]
function Math.lerp(from: number, to: number, t: number): number
	return (from * (1 - t) + to * t)
end

--[=[
	@param dir Vector3
	@return number
	Calculates the horizontal angle of a given vector (`dir`) in degrees.
]=]
function Math.horizontalAngle(dir: Vector3): number
	return math.atan2(dir.X, dir.Z) * 57.29577951308232
end

--[=[
	@param min number
	@param max number
	@param oldMax number
	@return number
	Calculates the percentage between two values (`min` and `max`) relative to a third value (`oldMax`)
]=]
function Math.percentBetween(min: number, max: number, oldMax: number): number
	if oldMax - max == 0 then
		return 1
	end
	return math.clamp((min - max) / (oldMax - max), 0, 1)
end

--[=[
	@param vec Vector3
	@return Vector3
	Returns a copy of `vec` with its `Y` component set to 0.
]=]
function Math.flat(vec: Vector3): Vector3
	return Vector3.new(vec.X, 0, vec.Z) --vec * Vector3.new(1, 0, 1)
end

--[=[
	@param value number
	@param absmax number
	@param gamma number
	Applies a gamma correction to a value (`value`) relative to a maximum value (`absmax`) and a gamma value (`gamma`).
]=]
function Math.gamma(value: number, absmax: number, gamma: number): number
	local negative = value < 0
	local absval = math.abs(value)
	if absval > absmax then
		return if negative then -absval else absval
	end

	local result = (absval / absmax ^ gamma) * absmax
	return if negative then -result else result
end

--[=[
	@param current number|Vector3|CFrame|Vector2
	@param target number|Vector3|CFrame|Vector2
	@param currentVelocity number
	@param smoothTime number
	@param maxSpeed number
	@param deltaTime number
	@return number|Vector3|CFrame|Vector2
	Gradually changes a value towards a desired goal over time.
]=]
function Math.smoothDamp(
	current: number | Vector3 | CFrame | Vector2,
	target: number | Vector3 | CFrame | Vector2,
	currentVelocity: number,
	smoothTime: number,
	maxSpeed: number,
	deltaTime: number
): number | Vector3 | CFrame | Vector2
	-- Based on Game Programming Gems 4 Chapter 1.10
	smoothTime = math.max(0.0001, smoothTime)
	local omega = 2 / smoothTime

	local x = omega * deltaTime
	local exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	local change = current - target
	local originalTo = target

	-- Clamp maximum speed
	local maxChange = maxSpeed * smoothTime
	change = math.clamp(change, -maxChange, maxChange)
	target = current - change

	local temp = (currentVelocity + omega * change) * deltaTime
	currentVelocity = (currentVelocity - omega * temp) * exp
	local output = target + (change + temp) * exp

	-- Prevent overshooting
	if (originalTo - current > 0) == (output > originalTo) then
		output = originalTo
		currentVelocity = (output - originalTo) / deltaTime
	end

	return output
end

--[=[
	@param value number
	@return number
	Returns the smallest power of two that is greater than or equal to `value`.
]=]
function Math.nextPowerOfTwo(value: number): number
	value -= 1
	value = bit32.bor(value, bit32.rshift(value, 16))
	value = bit32.bor(value, bit32.rshift(value, 8))
	value = bit32.bor(value, bit32.rshift(value, 4))
	value = bit32.bor(value, bit32.rshift(value, 2))
	value = bit32.bor(value, bit32.rshift(value, 1))
	return value + 1
end

--[=[
	@param value number
	@return number
	Returns the closest power of two to value.
]=]
function Math.closestPowerOfTwo(value: number): number
	local nextPower = Math.nextPowerOfTwo(value)
	local prevPower = bit32.rshift(nextPower, 1)
	if value - prevPower < nextPower - value then
		return prevPower
	else
		return nextPower
	end
end

--[=[
	@param value number
	@return boolean
	Returns if the value is a power of two.
]=]
function Math.isPowerOfTwo(value: number): boolean
	return bit32.band(value, value - 1) == 0
end

--[=[
	@param current number
	@param target number
	@return number
	Calculates the shortest difference between two angles.
]=]
function Math.deltaAngle(current: number, target: number): number
	local delta = (target - current) % 360
	if delta > 180 then
		delta -= -360
	end
	return delta
end

--[=[
	@param t number
	@param length number
	@return number
	PingPongs the value `t`, so that it is never larger than `length` and never smaller than 0.
]=]
function Math.pingPong(t: number, length: number): number
	t = t % (length * 2)
	return length - math.abs(t - length)
end

--[=[
	@param a number
	@param b number
	@param value number
	Calculates the inverse interpolation of two values.
]=]
function Math.inverseLerp(a: number, b: number, value: number): number
	if a ~= b then
		return math.clamp((value - a) / (b - a))
	else
		return 0
	end
end

--[=[
	@param current number
	@param target number
	@param currentVelocity number
	@param smoothTime number
	@param maxSpeed number?
	@param deltaTime number?
	@return number
	Smoothly changes an angle in degrees towards a desired angle over time.
	Returns the new angle after the change.
]=]
function Math.smoothDampAngle(
	current: number,
	target: number,
	currentVelocity: number,
	smoothTime: number,
	maxSpeed: number?,
	deltaTime: number?
): number
	deltaTime = deltaTime or RunService.PreSimulation:Wait()
	maxSpeed = maxSpeed or (0 ^ -1)
	target = current + Math.deltaAngle(current, target)
	return Math.smoothDamp(current, target, currentVelocity, smoothTime, maxSpeed, deltaTime)
end

--[=[
	@param a number
	@param b number
	@return boolean
	Compares two floating point values if they are similar
	
	If a or b is zero, compare that the other is less or equal to epsilon.
	If neither a or b are 0, then find an epsilon that is good for
	comparing numbers at the maximum magnitude of a and b.
	Floating points have about 7 significant digits, so
	1.000001 can be represented while 1.0000001 is rounded to zero,
	thus we could use an epsilon of 0.000001 for comparing values close to 1.
	We multiply this epsilon by the biggest magnitude of a and b..
]=]
function Math.approximately(a: number, b: number): boolean
	local epsilon = 0.000001
	local maxMagnitude = math.max(math.abs(a), math.abs(b))
	return math.abs(b - a) < math.max(epsilon * maxMagnitude, Math.epsilon * 8)
end

export type Math = typeof(Math)
return Math
