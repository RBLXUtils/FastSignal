local runService = game:GetService("RunService")

local Signal = {}
local signalFuncs = {}
local connectionFuncs = {}

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
	return setmetatable({
		_connections = {};
	}, {
		__index = signalFuncs
	})
end

function signalFuncs.Destroy(self)
	for i, connection in ipairs(self._connections) do
		connection:Disconnect()
		self._connections[i] = nil
	end
	setmetatable(self, nil)
	table.clear(self)
end

function signalFuncs.Fire(self, ...)
	for _, connection in pairs(self._connections) do
		if connection._fromScript.Parent == nil then
			connection:Disconnect()
		end
		if connection.Function then
			local thread = coroutine.create(connection.Function)
			coroutine.resume(thread, ...)
		end
	end
end

function signalFuncs.FireNoYield(self, ...)
	for _, connection in pairs(self._connections) do
		if connection._fromScript and connection._fromScript.Parent == nil then
			connection:Disconnect()
		end
		if connection.Function then
			local yields = doesYield(connection.Function, ...)
			if yields then
				error(":FireQueueNoYield() doesn't allow any connections to yield! Script interrupted!")
			end
		end
	end
end

function signalFuncs.Wait(self)
	local fired = false;
	
	local connection = self:Connect(function()
		fired = true
	end)
	local startTime = os.clock();
	
	repeat
		runService.Stepped:Wait()
	until fired or not connection.Connected
		
	connection:Disconnect()
	return os.clock() - startTime
end

function signalFuncs.Connect(self, givenFunction)
	assert(typeof(givenFunction) == "function", "You need to give a function.")
	
	local fromScript = getfenv(givenFunction).script
	
	local connection = setmetatable({
		Function = givenFunction;
		_fromScript = fromScript;
		Connected = true;
	}, {
		__index = connectionFuncs;
	})
	table.insert(self._connections, connection)
	return connection
end

function connectionFuncs.Disconnect(self)
	self.Function = nil;
	self.Connected = false
	setmetatable(self, nil)
end



return Signal
