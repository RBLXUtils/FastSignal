local runService = game:GetService("RunService")

local Signal = {}
Signal.__index = Signal

local function doesYield(func, ...)
	local packed = table.pack(...)
	local completed = false
	local thread = coroutine.create(function()
		func(table.unpack(packed))
		completed = true
	end)
	coroutine.resume(thread)
	return not completed
end

function Signal.new()

	local self = setmetatable({
		_connections = {}
	}, Signal)

	return self
end

function Signal:Destroy()
	for i, connection in ipairs(self._connections) do
		connection:Disconnect()
		self._connections[i] = nil
	end
	self = nil
end

function Signal:Fire(...)
	for _, connection in pairs(self._connections) do
		if connection.Function then
			local thread = coroutine.create(connection.Function)
			coroutine.resume(thread, ...)
		end
	end
end

function Signal:FireNoYield(...)
	for _, connection in pairs(self._connections) do
		if connection.Function then
			local yields = doesYield(connection.Function, ...)
			if yields then
				error(":FireQueueNoYield() doesn't allow any connections to yield! Script interrupted!")
			end
		end
	end
end

function Signal:Wait()
	local fired = false
	
	local connection = self:Connect(function()
		fired = true
	end)

	local startTime = os.clock()
	repeat
		runService.Stepped:Wait()
	until fired or not connection.Connected
		
	connection:Disconnect()
	return os.clock() - startTime
end

function Signal:Connect(givenFunction)
	assert(typeof(givenFunction) == "function", "You need to give a function.")
	
	local connection = {
		Function = givenFunction,
		Connected = true
	}
	table.insert(self, #self + 1, connection)

	return connection
end

function Signal:Disconnect()
	table.clear(self._connections)
end



return Signal
