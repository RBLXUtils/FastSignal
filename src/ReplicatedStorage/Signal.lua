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

			:SetName()
				Parameters: string
				Description:
					\\ Sets the name of a Signal

			:GetName()
				Returns: string
				Description:
					\\ Returns the Signal's current name

	Connection:

		Properties:

			.Connected
							
		Functions:

			:Disconnect()
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

local t_insert = table.insert
local c_running = coroutine.running
local c_yield = coroutine.yield
local t_defer = task.defer
local t_desynchronize = task.desynchronize

local ERROR_ON_ALREADY_DISCONNECTED = false
local TOSTRING_ENABLED = true

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

local function CleanDisconnections(self)
	--\\ Fired whenever all connections from a signal are fired,
	--   handles empty-ing connections.

	local _disconnections = self._disconnections
	if _disconnections == nil then
		return
	end
	self._disconnections = nil
	self._firing -= 1

	for _, connection in ipairs(_disconnections) do
		connection._next = nil
		connection._func = nil
	end
end


function Signal.new(name)
	local self = setmetatable({
		_name = typeof(name) == 'string' and name or "",
		_active = true,
		_head = nil,
		_firing = 0,
		_disconnections = nil
	}, Signal)

	return self
end

function Signal:IsActive()
	return self._active == true
end

local function Connect(self, func, is_wait)
	if not self:IsActive() then
		return setmetatable({
			Connected = false
		}, Connection)
	end

	local _head = self._head

	local connection = setmetatable({
		Connected = true,
		_func = func,
		_signal = self,
		_next = _head,
		_prev = nil,
		_is_wait = is_wait
	}, Connection)

	if _head ~= nil then
		_head._prev = connection
		connection._next = _head
	end

	self._head = connection

	return connection
end

function Signal:Connect(func)
	assert(
		typeof(func) == 'function',
		":Connect must be called with a function ".. self._name
	)

	return Connect(self, func)
end

function Signal:ConnectParallel(func)
	assert(
		typeof(func) == 'function',
		":ConnectParallel must be called with a function ".. self._name
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

	local _signal = self._signal
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

		_signal._head = _next
	end
	
	--\\ Safe to always wipe references to:

	self._signal = nil
	self._prev = nil

	local _disconnections = _signal._disconnections
	if _signal._firing ~= 0 then
		if _disconnections == nil then
			_disconnections = {}
			_signal._disconnections = _disconnections
		end
		t_insert(_disconnections, self)
		return
		--\\ Schedule to be fully cleaned up later.

	else
		self._func = nil
		self._next = nil
	end
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
		warn("Tried to :Fire destroyed signal ".. self._name)
		return
	end
	self._firing += 1

	local connection = self._head
	while connection ~= nil do
		t_defer(
			connection._func,
			...
		)
		
		if connection._is_wait then
			connection:Disconnect()
		end

		connection = connection._next
	end

	t_defer(
		CleanDisconnections,
		self
	)
end

function Signal:DisconnectAll()
	local connection = self._head
	while connection ~= nil do
		connection:Disconnect()
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

function Signal:GetName()
	return self._name
end

function Signal:SetName(name)
	assert(
		typeof(name) == 'string',
		"Name must be a string!"
	)

	self._name = name
end

function Signal:__tostring()
	return "Signal ".. self._name
end
if not TOSTRING_ENABLED then
	Signal.__tostring = nil
end

function Signal:__call(_, func)
	if not self:IsActive() then
		return
	end

	assert(
		typeof(func) == 'function',
		":Connect must be called with a function ".. self._name
	)

	return Connect(self, func)
end

return Signal
