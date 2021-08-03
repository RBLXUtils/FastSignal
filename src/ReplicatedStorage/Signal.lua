local USES_TOSTRING = false

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Signal:__tostring()
	return 
end
Signal.__tostring = USES_TOSTRING and Signal.__tostring or nil

function Signal.new()
	return setmetatable({
		Active = true,
		_head = nil
	}, Signal)
end

function Signal:Connect(func)
	if not self.Active then
		return
	end

	local connection = setmetatable({
		Connected = true,
		_func = func,
		_signal = self,
		_next = nil,
		_prev = nil
	}, Connection)

	local _head = self._head
	if _head then
		_head._next = Connection
		connection._prev = _head
	end
	self._head = connection

	return connection
end

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false

	local _signal = self._signal
	local _next = self._next
	local _prev = self._prev

	if _next then
		_next._prev = _prev
	end

	if _prev then
		_prev._next = _next
	end

	if self == _signal._head then
		_signal._head = _next
	end
end

function Signal:Fire(...)
	if not self.Active then
		return
	end

	local currentConnection = self._head
	while currentConnection ~= nil do
		if not currentConnection.Connected then
			currentConnection = currentConnection._next
			continue
		end

		task.defer(
			currentConnection._func,
			...
		)

		currentConnection = currentConnection._next
	end
end

function Signal:DisconnectAll()
	local currentConnection = self._head
	while currentConnection ~= nil do
		currentConnection:Disconnect()
	end
end

function Signal:Destroy()
	if not self.Active then
		return
	end

	self.Active = false
	self:DisconnectAll()
end

function Signal:SetName(name)
	assert(type(name) == 'string')

	self._name = name
end

return Signal
