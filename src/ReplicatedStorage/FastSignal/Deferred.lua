--[[
	ScriptSignal:

		.new()
			Returns: ScriptSignal
			Description:
				\\ Creates a new ScriptSignal object.

		:IsActive()
			Returns: boolean
			Description:
				\\ Returns a boolean determining
				\\ whether a ScriptSignal is active or not.

		:Fire(...)
			Parameters: ()...any)
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

		:SetName()
			Parameters: string
			Description:
				\\ Sets the name of a Signal

		:GetName()
			Returns: string
			Description:
				\\ Returns the Signal's current name

	ScriptConnection:

		Connected: boolean

		:Disconnect()
			Description:
				\\ Disconnects a connection.

]]

local ErrorsOnAlreadyDisconnected = false
local IsToStringEnabled = true

local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

-- Creates a ScriptSignal object
function ScriptSignal.new(name: string?)
	return setmetatable({
		_active = true,
		_name = typeof(name) == "string" and name or "",

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
)
	assert(
		typeof(handle) == 'function',
		":Connect must be called with a function -" .. self._name
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

	if _head ~= nil then
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
		":Connect must be called with a function -" .. self._name
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
	if self._active == false then
		warn("Tried to :Fire destroyed signal -" .. self._name)
		return
	end

	local node = self._head
	while node ~= nil do
		if node._connection ~= nil then
			task.defer(node._handle, ...)
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

	self._active = false
	self:DisconnectAll()
end

-- Returns the name given to the ScriptSignal
function ScriptSignal:GetName(): string
	return self._name
end

-- Sets the name of the ScriptSignal
function ScriptSignal:SetName(name: string)
	assert(
		typeof(name) == 'string',
		"Name must be a string!"
	)

	self._name = name
end

-- Disconnects a connection, any :Fire calls from now on would not
-- invoke this connection's function
function ScriptConnection:Disconnect()
	if self.Connected == false then
		if ErrorsOnAlreadyDisconnected then
			error("Can't disconnect twice", 2)
		end

		return
	end

	self.Connected = false

	local _node = self._node
	local node_next = _node._next
	local node_prev = _node._prev

	if node_next ~= nil then
		node_next._prev = node_prev
	end

	if node_prev ~= nil then
		 node_prev._next = node_next
	else
		-- _node == self._head

		_node._signal._head = node_next
	end

	self._node = nil
end
ScriptConnection.Destroy = ScriptConnection.Disconnect

function ScriptSignal:__tostring()
	return "Signal ".. self._name
end

if IsToStringEnabled == false then
	ScriptSignal.__tostring = nil
end

-- If the signal is called from inside a table,
-- it will behave like a :Connect call
function ScriptSignal:__call(
	_, handle: (...any) -> ()
)
	return self:Connect(handle)
end

export type Class = typeof(
	ScriptSignal.new()
)

export type ScriptConnection = typeof(
	ScriptSignal.new():Connect(function() end)
)

return ScriptSignal