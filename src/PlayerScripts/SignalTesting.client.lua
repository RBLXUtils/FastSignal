local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.FastSignal)
local GoodSignal = require(ReplicatedStorage.GoodSignal)

task.wait(5)

local function EmptyFunction()
	-- Empty
end

local IsDeferred do
	IsDeferred = false

	local Event = FastSignal.new()

	task.defer(function()
		local connection = Event:Connect(function()
			IsDeferred = true
		end)

		Event:Connect(function()
			connection:Disconnect()
		end)

		Event:Fire()
	end)

	Event:Wait()
	Event:Destroy()

	warn(
		"Is Signal Deferred: ".. (
			IsDeferred
				and "Yes"
				or "No"
		)
	)
end

local IsReverseOrder do
	IsReverseOrder = true

	local Event = FastSignal.new()
	local firstConnectionFired = false

	task.defer(function()
		Event:Connect(function()
			firstConnectionFired = true
		end)

		Event:Connect(function()
			if firstConnectionFired then
				IsReverseOrder = false
			end
		end)

		Event:Fire()
	end)

	Event:Wait()
	Event:Destroy()

	warn(
		"Is Connect Order Reverse: ".. (
			IsReverseOrder
				and "Yes"
				or "No"
		)
	)
end

local DisconnectTest do
	local Event = FastSignal.new()
	local connection = Event:Connect(EmptyFunction)

	connection:Disconnect()

	warn(
		"Does :Disconnect disconnect a connection properly: ".. (
			connection.Connected == false and connection.__node == nil and Event._head == nil
				and "Yes"
				or "No"
		)
	)
end

local DestroyTest do
	local Event = FastSignal.new()
	local connection = Event:Connect(EmptyFunction)

	Event:Destroy()

	warn(
		"Does :Destroy disconnect connections properly: ".. (
			connection.Connected == false and connection._node == nil and Event._head == nil
				and "Yes"
				or "No"
		)
	)

	warn(
		"Does :Destroy make Signal not connect future connections: ".. (
			Event:Connect(EmptyFunction).Connected == false
				and "Yes"
				or "No"
		)
	)
end

local ErrorTest do
	warn("Error testing:")

	local BindableEvent = Instance.new("BindableEvent")
	BindableEvent.Event:Connect(function()
		error("FastSignal stacktrace test")
	end)

	BindableEvent:Fire()

	local Event = FastSignal.new()
	Event:Connect(function()
		error("FastSignal stacktrace test")
	end)

	Event:Fire()
end

-- Benchmarks:

-- Benchmarks were done in Immediate mode, speed can be affected heavily on Deferred
-- under certain cases.

warn("Benchmarks:")

task.wait(2.5)

local ConnectSpeed do
	local function Benchmark(Event)
		local Connect = Event.Connect
		-- Avoid indexing speeds, those are pretty important, but it's nice to test it
		-- without them.

		local totalTime = 0
		for _ = 1, 1000 do
			local timeTook = os.clock()
			Connect(Event, EmptyFunction)
			timeTook = os.clock() - timeTook

			totalTime += timeTook
		end

		return totalTime
	end

	local RBXSignalTime = Benchmark( Instance.new("BindableEvent").Event )
	local GoodSignalTime = Benchmark( GoodSignal.new() )
	local FastSignalTime = Benchmark( FastSignal.new() )

	warn(
		(":Connect \n RBXScriptSignal: %s \n GoodSignal: %s \n FastSignal: %s \n")
			:format(RBXSignalTime, GoodSignalTime, FastSignalTime)
	)

	--[[
		Expectations:

		RBXScriptSignal loses by a long shot, while FastSignal loses slightly by GoodSignal.
			Why? I believe this is because RBXScriptSignals have to
			listen to the script that made that connection
			for when it is destroyed / deactivated,
			so it can disconnect it.

		This is expected as FastSignal uses two tables for connections and GoodSignal uses one.
		FastSignal does this for memory management reasons, it prevents accidental leaks.

		Results:

			Well, the expectations sometimes are accurate, sometimes not, and when they're not
			they can be a lot of times quite faster than GoodSignal. Don't know why.
	]]
end

task.wait(2.5)

local FireSpeed do
	local Mode = "ConnectionStress" -- "NoConnections" / "ConnectionStress"

	warn("Fire Benchmark Mode:", Mode)

	local function ConnectionsSetup(Event)
		if Mode ~= "ConnectionStress" then
			return
		end

		for _ = 1, 1000 do
			Event:Connect(EmptyFunction)
		end
	end

	local function Benchmark(Event)
		ConnectionsSetup(Event.Event or Event)

		local Fire = Event.Fire

		local totalTime = 0
		for _ = 1, 1000 do
			local timeTook = os.clock()
			Fire(Event)
			timeTook = os.clock() - timeTook

			totalTime += timeTook
		end

		return totalTime
	end

	local RBXSignalTime = Benchmark( Instance.new("BindableEvent") )
	local FastSignalTime = Benchmark( FastSignal.new() )
	local GoodSignalTime = Benchmark( GoodSignal.new() )

	warn(
		(":Fire\n RBXScriptSignal: %f \n GoodSignal: %f \n FastSignal: %f")
			:format(RBXSignalTime, GoodSignalTime, FastSignalTime)
	)

	--[[
		Expectations:

			BindableEvent loses by a long shot.
			In all scenearios.

			NoConnections:

			A tie.

			ConnectionStress:

			A tie.

		Results:

			NoConnections:

			BindableEvents don't lose from all that much in here actually, still loses,
			but not as much as I expected.

			FastSignal loses slightly to GoodSignal, the only reason I can think of
			why that's the case is that GoodSignal doesn't use nil, it uses false.
			So a head always technically exists, so maybe that makes searching
			an index slightly slower.

			ConnectionStress:

			In this case, BindableEvents WIN. Yeah, even from GoodSignal.
			Not by much, but they seem to be consistently winning by 0.1 seconds.

			GoodSignal and FastSignal are staying in 0.57 seconds, while
			BindableEvents stay at a 0.43!
500
			FastSignal sometimes seems to win over GoodSignal in this case, by a small amount
			though.

			Note:

			Not recycling threads (and by extension, deferred mode) can cause
			the speed of firing to be 5x slower.

			However, this is under a sceneario where the connected handler is empty.
			Realistically, you might have some expensive connections.
			Sometimes, that trade-off might be worth it for you, as firing wouldn't slow down
			everything immediately.
	]]
end

task.wait(2.5)

local DisconnectBenchmark do
	-- This test only benchmark the speed of a signal
	-- that only has one node, where I expect FastSignal to lose, FastSignal
	-- is optimized for multiple connections.

	-- A benchmark for that might be added soon.

	local function Benchmark(Event)
		local totalTime = 0

		local Disconnect = Event:Connect(EmptyFunction)
		Disconnect = Disconnect:Disconnect() or Disconnect.Disconnect

		for _ = 1, 1000 do
			local connection = Event:Connect(EmptyFunction)

			local timeTook = os.clock()
			Disconnect(connection)
			timeTook = os.clock() - timeTook

			totalTime += timeTook
		end

		return totalTime
	end

	local RBXSignalTime = Benchmark( Instance.new("BindableEvent").Event )
	local GoodSignalTime = Benchmark( GoodSignal.new() )
	local FastSignalTime = Benchmark( FastSignal.new() )

	warn(
		(":Disconnect \n RBXScriptSignal: %s \n GoodSignal: %s \n FastSignal: %s")
			:format(RBXSignalTime, GoodSignalTime, FastSignalTime)
	)

	--[[
		Expectations:

			BindableEvent loses by a long shot.

			FastSignal loses to GoodSignal, GoodSignal doesn't have a previous reference
			in its connection nodes, FastSignal does, and that's for disconnecting older
			connections in an optimized manner, however, for single connections that means
			that it would need one more table search.

			FastSignal also has one extra table search for just finding the _node
			reference on the ScriptConnection object.

			Things are not looking good for FastSignal here.

		Results:

			Note: After a BUG FIX of all things, FastSignal seems to be winning in
			this benchmark sometimes, sometimes losing. As far as I tested,
			FastSignal seems to be winning more frequently at least in machine.
			This might not be the case for you.

	]]
end

task.wait(2.5)

local DisconnectMultipleBenchmark do
	local numberOfConnections = 1000
	local mode = "Random" -- "Random" / "Ordered"
	-- TODO: Implement Ordered

	local function Benchmark(Signal)
		local connections = table.create(numberOfConnections)
		if mode == "Random" then
			local allNumbers = {}
			for i = 1, numberOfConnections do
				allNumbers[i] = i
			end
	
			local randomizedIndexes = table.create(numberOfConnections) do
				local allNumbers = table.create(numberOfConnections) do
					for i = 1, numberOfConnections do
						allNumbers[i] = i
					end
				end
				
				while #allNumbers ~= 0 do
					local randomNumber = math.random(1, #allNumbers)
					table.insert(randomizedIndexes, allNumbers[randomNumber])
					table.remove(allNumbers, randomNumber)
				end
			end

			local connections = table.create(numberOfConnections)
			for i = 1, numberOfConnections do
				connections[ randomizedIndexes[i] ] = Signal:Connect(function()
					
				end)
			end

			local benchmarkTime = os.clock()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end
			benchmarkTime = os.clock() - benchmarkTime

			return benchmarkTime
		end
	end
	
	local results = {
		["FastSignal"] = Benchmark(FastSignal.new());
		["GoodSignal"] = Benchmark(GoodSignal.new());
		["RBXScriptSignal"] = Benchmark(Instance.new("BindableEvent").Event)
	}

	warn("MultipleDisconnect:\n Mode:", mode, "Results:", results)

	--[[
		Conclusion:

		It has been a while since I messed with Signals and Roblox overall, but I wanted to test this. This test is not fully implemented and there is more to do.
		This test is meant to benchmark the benchmark of :Disconnect when indexes are chosen at random, e.g. with multiple connections on a single signal

		In this test, the conclusion is that GoodSignal and RBXScriptSignal fall behind. This most likely has to do with FastSignal implementing a linked list with a
		reference to the last node, while this adds a slight overhead for the previous benchmarks, it provides a better result for this.
	]]
end

--[[
	TODO:

	* Add a alternative Disconnect benchmark which benchmarks disconnecting multiple connections (almost done)
	* Add a Wait benchmark
]]