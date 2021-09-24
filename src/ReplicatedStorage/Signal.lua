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

local ErrorsOnAlreadyDisconnected = false
local IsToStringEnabled = true

local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal
ScriptSignal.ClassName = "ScriptSignal"

local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

function ScriptSignal.new(name: string?)
	return setmetatable({
		_active = true,
		_name = typeof(name) == "string" and name or "",

		_head = nil
	}, ScriptSignal)
end

function ScriptSignal:IsA(className: string): boolean
	return self.ClassName == className
end

function ScriptSignal:IsActive(): boolean
	return self._active == true
end

function ScriptSignal:Connect(
	handle: (...any) -> ()
)
	if self._active == false then
		return setmetatable({
			Connected = false
		}, ScriptConnection)
	end

	assert(
		typeof(handle) == 'function',
		":Connect must be called with a function -" .. self._name
	)

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


function ScriptSignal:Fire(...)
	if self._active == false then
		warn("Tried to :Fire destroyed signal -" .. self._name)
		return
	end

	local node = self._head
	while node ~= nil do
		task.defer(node._handle, ...)

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

	self._active = false
	self:DisconnectAll()
end

function ScriptSignal:GetName(): string
	return self._name
end

function ScriptSignal:SetName(name: string)
	assert(
		typeof(name) == 'string',
		"Name must be a string!"
	)

	self._name = name
end

function ScriptSignal:__tostring()
	return "Signal " .. self._name
end

if IsToStringEnabled == false then
	ScriptSignal.__tostring = nil
end

function ScriptSignal:__call(
	_, handle: (...any) -> ()
)
	assert(
		typeof(handle) == "function",
		":Connect must be called with a function -" .. self._name
	)

	if self._active == false then
		return setmetatable({
			Connected = false,
		}, ScriptConnection)
	end

	return self:Connect(handle)
end

export type ScriptSignal = typeof(
	setmetatable({}, ScriptSignal)
)

export type ScriptConnection = typeof(
	setmetatable({Connected = true}, ScriptConnection)
)

return ScriptSignal
