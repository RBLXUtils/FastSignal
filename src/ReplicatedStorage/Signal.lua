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

local c_running = coroutine.running
local c_yield = coroutine.yield
local t_defer = task.defer
local t_desynchronize = task.desynchronize

local ERROR_ON_ALREADY_DISCONNECTED = false

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Signal.new()
	local self = setmetatable({
		[1] = nil, -- _head
		[2] = true -- _active
	}, Signal)

	return self
end

function Signal:IsActive()
	return self[2] == true
end

local function Connect(self, func, self_disconnects)
	if not self:IsActive() then
		return setmetatable({
			Connected = false
		}, Connection)
	end

	local _head = self[1]

	local connection = setmetatable({
		Connected = true,
		[1] = func, -- _func
		[2] = self, -- _signal
		[3] = _head, -- _next
		[4] = nil, -- _prev
		[5] = self_disconnects -- _self_disconnects
	}, Connection)

	if _head ~= nil then
		_head[4] = connection -- _head._prev = connection
		connection[3] = _head -- connection._next = _head
	end

	self[1] = connection -- _head = connection

	return connection
end

function Signal:Connect(func)
	assert(
		typeof(func) == 'function',
		":Connect must be called with a function"
	)

	return Connect(self, func)
end

function Signal:ConnectParallel(func)
	assert(
		typeof(func) == 'function',
		":ConnectParallel must be called with a function"
	)

	return Connect(self, function(...)
		t_desynchronize()
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

	local _next = self[3]
	local _prev = self[4]

	if _next ~= nil then
		_next[4] = _prev -- _next._prev = _prev
	end

	if _prev ~= nil then
		_prev[3] = _next -- _prev._next = _next
	else
		--\\ This connection was the _head,
		--   therefore we need to update the head
		--   to the connection after this one.

		self[2][1] = _next -- self._signal._head = _next
	end
	
	--\\ Safe to wipe references to:

	self[2] = nil
	self[4] = nil
end

function Signal:Wait()
	Connect(
		self,
		c_running(),
		true
	)

	return c_yield()
end

function Signal:Fire(...)
	if not self:IsActive() then
		warn("Tried to :Fire destroyed signal")
		return
	end

	local connection = self[1]
	while connection ~= nil do
		t_defer(
			connection[1],
			...
		)
		
		if connection[5] then
			-- If connection is one-fire only:
			connection:Disconnect()
		end

		connection = connection[3] --> _next
	end
end

function Signal:DisconnectAll()
	local connection = self[1] -- _head
	while connection ~= nil do
		connection.Connected = false
		connection[2] = nil -- _signal = nil
		connection[4] = nil -- _prev = nil

		connection = connection[3] --> _next
	end
	self[1] = nil -- _head = nil
end

function Signal:Destroy()
	if not self:IsActive() then
		return
	end

	self[2] = false
	self:DisconnectAll()
end

function Signal:__call(_, func)
	if not self:IsActive() then
		return
	end

	assert(
		typeof(func) == 'function',
		":Connect must be called with a function"
	)

	return Connect(self, func)
end

return Signal
