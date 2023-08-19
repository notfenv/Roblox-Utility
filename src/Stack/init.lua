-- Stack
-- Mia Vince
-- February 06, 2022

local insert = table.insert
local remove = table.remove

--[=[
    @class Stack
    A Stack is helpful for sorting objects in a list, where the highest/first value is retrieved.
    ```lua
    local stack = Stack.new()
    stack:Push("world!")
    stack:Push("Hello")
    print(stack:IsEmpty(), stack:Len()) -- false 2
    print(stack:Pop(), stack:Pop()) -- Hello world!
    print(stack:IsEmpty(), stack:Len()) -- true 0
    ```
]=]
local Stack = {}
Stack.__index = Stack

--[=[
    Constructs a Stack object
]=]
function Stack.new()
	local self = setmetatable({
		_list = {},
	}, Stack)
	return self
end

--[=[
    @param value any
    Pushes a new `value` in front of the stack.
]=]
function Stack:Push(value)
	insert(self._list, value)
end

--[=[
    @param key number
    @param value any
    Adds a new `value` dictated by the `key`.
]=]
function Stack:Set(key, value)
	insert(self._list, key, value)
end

--[=[
    @return any
    Finds and removes the first/highest value and returns it.
]=]
function Stack:Pop()
	return remove(self._list, 1)
end

--[=[
    @return boolean
    Returns if the stack's list is empty.
]=]
function Stack:IsEmpty()
	return self:Len() == 0
end

--[=[
    @return number
    Returns how many items are in the stack.
]=]
function Stack:Len()
	return #self._list
end

return Stack
