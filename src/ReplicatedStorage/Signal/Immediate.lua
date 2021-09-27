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

local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

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

function ScriptSignal.new()
	return setmetatable({
		_active = true,
		_head = nil
	}, ScriptSignal)
end

function ScriptSignal:IsActive(): boolean
	return self._active == true
end

function ScriptSignal:Connect(
	handle: (...any) -> ()
)
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
		_handle = handle,
		_connection = nil,

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

function ScriptSignal:Fire(...)
	local node = self._head
	while node ~= nil do
		if FreeThread == nil then
			FreeThread = coroutine.create(RunHandlerInFreeThread)
		end

		task.spawn(
			FreeThread :: thread,
			node._handle,
			...
		)

		node = node._next
	end
end

function ScriptSignal:DisconnectAll()
	local node = self._head
	while node ~= nil do
		node._connection:Disconnect()

		node = node._next
	end
end

function ScriptSignal:Destroy()
	if self._active == false then
		return
	end

	self:DisconnectAll()
	self._active = false
end

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

export type ScriptSignal = typeof(
	setmetatable({}, ScriptSignal)
)

export type ScriptConnection = typeof(
	setmetatable({Connected = true}, ScriptConnection)
)

return ScriptSignal
