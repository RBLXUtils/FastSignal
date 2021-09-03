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


local function assert(condition, errorMessage)
	-- Assert function which errors on top of the
	-- function on which assert was called on.
	-- Assert usually errors on the function it was called, not on the top one.

	if condition then
		return
	end

	error(errorMessage, 3)
end

local ERROR_ON_ALREADY_DISCONNECTED = false
local TOSTRING_ENABLED = true

type Connection = {
	Connected: boolean,
	Disconnect: () -> (),
}

type Signal = {
	Fire: (any) -> (),

	Connect: ( () -> () ) -> Connection,
	ConnectParralel: ( () -> () ) -> Connection,
	Wait: () -> any,
	
	IsActive: () -> boolean,
	DisconnectAll: () -> (),
	Destroy: () -> (),

	GetName: () -> (string),
	SetName: (string) -> (),
}

local Signal  = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Signal.new(name: string?): Signal
	local self = setmetatable({
		_name = typeof(name) == 'string' and name or "",
		_active = true,
		_head = nil
	}, Signal)

	return self
end

function Signal:IsActive(): boolean
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
	end

	self._head = connection

	return connection
end

function Signal:Connect(func): Connection
	assert(
		typeof(func) == 'function',
		":Connect must be called with a function ".. self._name
	)

	return Connect(self, func)
end

function Signal:ConnectParallel(func): Connection
	assert(
		typeof(func) == 'function',
		":ConnectParallel must be called with a function ".. self._name
	)

	return Connect(self, function(...)
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
	

	self._func = nil
	self._signal = nil
	self._next = nil
	self._prev = nil
end

function Signal:Wait(): any
	Connect(
		self,
		coroutine.running(),
		true
	)

	return coroutine.yield()
end

function Signal:Fire(...)
	if not self:IsActive() then
		warn("Tried to :Fire destroyed signal ".. self._name)
		return
	end

	local connection = self._head
	while connection ~= nil do
		task.defer(
			connection._func,
			...
		)
		
		if connection._is_wait then
			local nextConnection = connection._next

			connection:Disconnect()

			connection = nextConnection
			continue
		end

		connection = connection._next
	end
end

function Signal:DisconnectAll()
	local connection = self._head
	while connection ~= nil do
		local nextConnection = connection._next

		connection:Disconnect()

		connection = nextConnection
	end
end

function Signal:Destroy()
	if not self:IsActive() then
		return
	end

	self._active = false
	self:DisconnectAll()
end

function Signal:GetName(): string
	return self._name
end

function Signal:SetName(name: string)
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
