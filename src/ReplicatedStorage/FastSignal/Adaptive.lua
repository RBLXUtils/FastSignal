--[[
	ScriptSignal:

		Functions:

			.new()
				Returns: ScriptSignal
				Description:
					\\ Creates a new ScriptSignal object.

			:IsActive()
				Returns: boolean
				Description:
					\\ Returns whether a ScriptSignal is active or not.

			:Fire(...)
				Parameters: any
				Description:
					\\ Fires a ScriptSignal with any arguments.

			:Connect()
				Returns: ScriptConnection
				Parameters: function: (...any) -> ()
				Description:
					\\ Connects a function to a ScriptSignal.

			:ConnectOnce()
				Parameters: function: (...any) -> ()
				Description:
					\\ Runs the function given only on the first fire since
					\\ the connection was connected

			:Wait()
				Returns: (...any)
				Description:
					\\ Yields until the Signal it belongs to is fired.
					\\ Will return the arguments it was fired with.

			:Destroy()
				Description:
					\\ Destroys a ScriptSignal, all connections are then disconnected.

			:DisconnectAll()
				Description:
					\\ Disconnects all connections without destroying the Signal.

	ScriptConnection:

		Properties:

			.Connected: boolean

		Functions:

			:Disconnect()
				Description:
					\\ Disconnects a connection.

]]

local IsDeferred: boolean do
	IsDeferred = false

	local thread = coroutine.running()

	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function()
		-- Last connection ran

		task.defer(thread)
	end)

	local connection = bindable.Event:Connect(function()
		-- Second connection ran

		IsDeferred = true
	end)

	bindable.Event:Connect(function()
		-- First connection ran

		connection:Disconnect()
	end)

	bindable:Fire()

	coroutine.yield()
	bindable:Destroy()
end

local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

local RunListener

if IsDeferred then
	RunListener = task.defer
else
	local FreeThread: thread? = nil

	local function RunHandler(handle, ...)
		local thread = FreeThread :: thread
		FreeThread = nil

		handle(...)

		FreeThread = thread
	end

	local function RunHandlerInFreeThread(...)
		RunHandler(...)

		while true do
			RunHandler( coroutine.yield() )
		end
	end

	function RunListener(handle, ...)
		if FreeThread == nil then
			FreeThread = coroutine.create(RunHandlerInFreeThread)
		end

		task.spawn(
			FreeThread :: thread,
			handle, ...
		)
	end
end

-- Creates a ScriptSignal object
function ScriptSignal.new(): Class
	return setmetatable({
		_active = true,
		_head = nil
	}, ScriptSignal)
end

-- Returns a boolean determining if the ScriptSignal object is usable
function ScriptSignal:IsActive(): boolean
	return self._active == true
end

-- Connects a function to the ScriptSignal object
function ScriptSignal:Connect(
	handle: (...any) -> ()
): ScriptConnection

	assert(
		typeof(handle) == 'function',
		"Must be function"
	)

	if self._active == false then
		return setmetatable({
			Connected = false
		}, ScriptConnection)
	end

	local _head = self._head

	local node = {
		_signal = self,
		_connection = nil,
		_handle = handle,

		_next = _head,
		_prev = nil
	}

	if _head then
		_head._prev = node
	end
	self._head = node

	local connection = setmetatable({
		Connected = true,

		_node = node
	}, ScriptConnection)

	node._connection = connection

	return connection
end

-- Connects a function to a ScriptSignal object, but only allows that
-- connection to run once; any later fires won't trigger anything
function ScriptSignal:ConnectOnce(
	handle: (...any) -> ()
)
	assert(
		typeof(handle) == 'function',
		"Must be function"
	)

	local connection
	connection = self:Connect(function(...)
		if connection == nil then
			return
		end

		connection:Disconnect()
		connection = nil

		handle(...)
	end)
end

-- Yields the current thread until the signal is fired, returns what
-- it was fired with
function ScriptSignal:Wait(): (...any)
	local thread do
		thread = coroutine.running()

		local connection
		connection = self:Connect(function(...)
			if connection == nil then
				return
			end

			connection:Disconnect()
			connection = nil

			task.spawn(thread, ...)
		end)
	end

	return coroutine.yield()
end

-- Fires a ScriptSignal object with the arguments passed through it
function ScriptSignal:Fire(...)
	local node = self._head
	while node ~= nil do
		if node._connection ~= nil then
			RunListener(node._handle, ...)
		end

		node = node._next
	end
end

-- Disconnects all connections from a ScriptSignal object
-- without destroying it and without making it unusable
function ScriptSignal:DisconnectAll()
	local node = self._head
	while node ~= nil do
		local _connection = self._connection
		if _connection ~= nil then
			_connection:Disconnect()
		end

		node = node._next
	end
end

-- Destroys a ScriptSignal object, disconnecting all connections
-- and making it unusable.
function ScriptSignal:Destroy()
	if self._active == false then
		return
	end

	self:DisconnectAll()
	self._active = false
end

-- Disconnects a connection, any :Fire calls from now on would not
-- invoke this connection's function
function ScriptConnection:Disconnect()
	if self.Connected == false then
		return
	end

	self.Connected = false

	local _node = self._node
	local _prev = self._prev
	local _next = self._next

	if _next then
		_next._prev = _prev
	end

	if _prev then
		_prev._next = _next
	else
		-- _node == _signal._head

		_node._signal._head = _next
	end

	_node._connection = nil
	self._node = nil
end

ScriptConnection.Destroy = ScriptConnection.Disconnect

export type Class = typeof(
	setmetatable({}, ScriptSignal)
)

export type ScriptConnection = typeof(
	setmetatable({Connected = true}, ScriptConnection)
)

return ScriptSignal