--!strict
-- Mutex
-- Mia Vince
-- June 08, 2023

--[=[
    @class Mutex
    A mutex provides a mutual exclusion synchronization mechanism for controlling
    access to shared resources. It ensures that only one thread or process can
    acquire the lock at a time, preventing concurrent access and potential conflicts.

    Example usage:
    ```lua
    local Mutex = require(path.to.Mutex)

    local myMutex = Mutex.new()

    -- Thread 1
    coroutine.wrap(function()
        print("Thread 1: Attempting to lock the mutex")
        myMutex:Lock()
        print("Thread 1: Mutex locked")

        -- Do some critical section operations

        print("Thread 1: Unlocking the mutex")
        myMutex:Unlock()
        print("Thread 1: Mutex unlocked")
    end)()

    -- Thread 2
    coroutine.wrap(function()
        print("Thread 2: Attempting to lock the mutex")
        myMutex:Lock()
        print("Thread 2: Mutex locked")

        -- Do some critical section operations

        print("Thread 2: Unlocking the mutex")
        myMutex:Unlock()
        print("Thread 2: Mutex unlocked")
    end)()
    ```
]=]
local Mutex = {}
Mutex.__index = Mutex

--[=[
    Creates a new Mutex object.
    @return Mutex
]=]
function Mutex.new()
	local self = {}
	setmetatable(self, Mutex)
	self._locked = false
	self._queue = {}
	return self
end

--[=[
    Locks the mutex. If the mutex is already locked, the
    current thread will be added to the queue and suspended
    until the lock is released.
]=]
function Mutex:Lock()
	if self._locked then
		-- Mutex is already locked, add the current thread to the queue
		local currentThread = coroutine.running()
		table.insert(self._queue, currentThread)
		coroutine.yield()
	else
		-- Mutex is available, lock it immediately
		self._locked = true
	end
end

--[=[
    Unlocks the mutex. If there are threads waiting in the queue,
    the next thread will be resumed and granted the lock.
    If the mutex is not locked or there are no waiting threads,
    an error will propagate.
]=]
function Mutex:Unlock()
	assert(self._locked, `Attempting to unlock an unlocked mutex`)
	if #self._queue > 0 then
		-- There are threads waiting in the queue, resume the next thread
		local nextThread = table.remove(self._queue, 1)
		if not nextThread then
			return
		end
		coroutine.resume(nextThread)
	else
		-- No threads are waiting, unlock the mutex
		self._locked = false
	end
end

export type Mutex = typeof(Mutex.new(...))
return Mutex
