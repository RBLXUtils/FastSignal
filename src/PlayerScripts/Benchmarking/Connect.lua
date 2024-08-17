--!optimize 2
--!nocheck
--!native

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

local NumberOfIterations = 1000
local NumberOfBenchmarks = 3

local function singleBenchmark(event)
	local Connect = event.Connect
	-- Avoid indexing speeds, those are important, but it's nice to test it
	-- without them.

	local initialTime = os.clock()
	for _ = 1, NumberOfIterations do
		Connect(event, function() end) -- Luau has an optimization where equal functions are cached
	end

	return os.clock() - initialTime
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