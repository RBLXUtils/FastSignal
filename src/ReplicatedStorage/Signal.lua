--[[
	Library:

		Functions:

			.new()
				Returns: Signal
				
				Description:
					\\ Creates a new Signal object.

	Signal:

		Functions:

			:IsActive()
				Returns: boolean
				Description:
					\\ Returns whether a ScriptSignal is active or not.

			:Fire(...)
				Parameters: any
				Description:
					\\ Fires a ScriptSignal with any arguments.

			:Connect()
				Returns: Connection
				Parameters: function
				Description:
					\\ Connects a function to a ScriptSignal.

			:Wait()
				Returns: any
				Description:
					\\ Yields until the Signal it belongs to is fired.
					\\ Will return the arguments it was fired with.

			:Destroy()
				Description:
					\\ Destroys a ScriptSignal, all connections are then disconnected.
			
			:DisconnectAll()
				Description:
					\\ Disconnects all connections without destroying the Signal.

	Connection:

		Properties:

			Connection.Connected
							
		Functions:

			Connection:Disconnect()
				Description:
					\\ Disconnects a connection.

		Extra:

			This Signal Class can be used to make shortcuts to connector functions.
			Example:

				local Event = Signal.new()
				local Class = {}
				Class.ListenToChanged = Event

				Class.ListenToChanged:Connect(function()
					print("Fired!")
					-- Valid (obviously)
				end)

				Class:ListenToChanged(function()
					print("Fired!")
					-- ^ Valid, can be used for things like these
				end)

			Note that you shouldn't call a Signal unless it's being used in this form.
			
]]

local ERROR_ON_ALREADY_DISCONNECTED = false

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Signal:__call(_, ...)
	if not self:IsActive() then
		return
	end

	return self:Connect(...)
end

function Signal.new()
	local self = setmetatable({
		_active = true,
		_head = nil
	}, Signal)

	return self
end

function Signal:IsActive()
	return self._active == true
end

function Signal:Connect(func)
	assert(
		typeof(func) == 'function',
		":Connect must be called with a function"
	)

	if not self:IsActive() then
		return setmetatable({
			Connected = false
		}, Connection)
	end

	local connection = setmetatable({
		Connected = true,
		_func = func,
		_signal = self,
		_next = nil,
		_prev = nil
	}, Connection)

	local _head = self._head
	if _head ~= nil then
		_head._prev = connection
		connection._next = _head
	end

	self._head = connection

	return connection
end

function Signal:ConnectParallel(func)
	assert(
		typeof(func) == 'function',
		":ConnectParallel must be called with a function"
	)

	return self:Connect(function(...)
		task.desynchronize()
		func(...)
	end)
end

function Connection:Disconnect()
	if not self.Connected then
		if ERROR_ON_ALREADY_DISCONNECTED then
			error("Can't disconnect twice", 2)
		end

		return
	end

	self.Connected = false

	local _next = self._next
	local _prev = self._prev

	if _next ~= nil then
		_next._prev = _prev
	end

	if _prev ~= nil then
		_prev._next = _next
	else
		--\\ This connection was the _head,
		--   therefore we need to update the head
		--   to the connection after this one.

		self._signal._head = _next
	end
	
	--\\ Safe to wipe references to:

	self._signal = nil
	self._prev = nil
end

function Signal:Wait()
	if not self:IsActive() then
		warn("Tried to :Wait on destroyed signal")
		return
	end
	
	local thread = coroutine.running()

	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()

		task.spawn(
			thread,
			...
		)
	end)

	return coroutine.yield()
end

function Signal:Fire(...)
	if not self:IsActive() then
		warn("Tried to :Fire destroyed signal")
		return
	end

	local connection = self._head
	while connection ~= nil do
		task.defer(
			connection._func,
			...
		)

		connection = connection._next
	end
end

function Signal:DisconnectAll()
	local connection = self._head
	while connection ~= nil do
		--connection:Disconnect()

		connection.Connected = false
		connection._prev = nil
		connection._signal = nil

		connection = connection._next
	end
	self._head = nil
end

function Signal:Destroy()
	if not self:IsActive() then
		return
	end

	self._active = false
	self:DisconnectAll()
end

return Signal
