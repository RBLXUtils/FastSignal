--!optimize 2
--!native

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

-- This test only benchmark the speed of a signal
-- that only has one node, where I expect FastSignal to lose, FastSignal
-- is optimized for multiple connections and random access.

local NumberOfIterations = 1000
local NumberOfBenchmarks = 3

local function singleBenchmark(Event)
	local Disconnect = Event:Connect(function()
		
	end)
	Disconnect = Disconnect:Disconnect() or Disconnect.Disconnect

	local totalTime = 0
	for _ = 1, NumberOfIterations do
		local connection = Event:Connect(function()

		end)

		local initialTime = os.clock()
		Disconnect(connection)
		totalTime += os.clock() - initialTime
	end

	return totalTime
end

return function(event)
	local results = table.create(NumberOfBenchmarks)
	for _ = 1, NumberOfBenchmarks do
		local result = singleBenchmark(event)
		table.insert(results, result)
		task.wait()
	end

	local average = 0
	for _, result in ipairs(results) do
		average += result
	end
	average = average / NumberOfBenchmarks

	return average
end