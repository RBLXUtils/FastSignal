local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastSignal = require(ReplicatedStorage.FastSignal)
local GoodSignal = require(ReplicatedStorage.GoodSignal)

task.wait(7.5)

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

local ErrorTest do
	warn("Error testing:")

	local BindableEvent = Instance.new("BindableEvent")
	BindableEvent.Event:Connect(function()
		(2 + 2).cool()
	end)

	BindableEvent:Fire()

	local Event = FastSignal.new()
	Event:Connect(function()
		(2 + 2).cool()
	end)

	Event:Fire()
end

-- Benchmarks:

-- Benchmarks were done in Immediate mode, speed can be affected heavily on Deferred
-- under certain cases.

warn("Benchmarks:")

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

		Results: Same as expectations
	]]
end

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

--[[
	TODO:

	* Add a Disconnect benchmark (this is gonna be interesting)
	* Add a Wait benchmark (not so much because the thing that would make it slower is being removed)
]]