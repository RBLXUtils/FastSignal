--[[
	Conclusion:

	It has been a while since I messed with Signals and Roblox overall, but I wanted to test this. This test is not fully implemented and there is more to do.
	This test is meant to benchmark the benchmark of :Disconnect when indexes are chosen at random, e.g. with multiple connections on a single signal

	In this test, the conclusion is that GoodSignal and RBXScriptSignal fall behind. This most likely has to do with FastSignal implementing a linked list with a
	reference to the last node, while this adds a slight overhead for the previous benchmarks, it provides a better result for this.
]]

local Mode = "Random"
local NumberOfIterations = 1000 -- In this case, the number of connections
local NumberOfBenchmarks = 3
-- TODO: Implement Ordered

local RandomizedIndexes = table.create(NumberOfIterations) do
	local allNumbers = table.create(NumberOfIterations) do
		for i = 1, NumberOfIterations do
			allNumbers[i] = i
		end
	end

	while #allNumbers ~= 0 do
		local randomNumber = math.random(1, #allNumbers)
		table.insert(RandomizedIndexes, allNumbers[randomNumber])
		table.remove(allNumbers, randomNumber)
	end
end

local function singleBenchmark(Signal)
	local connections = table.create(NumberOfIterations)
	if Mode == "Random" then
		local connections = table.create(NumberOfIterations)
		for i = 1, NumberOfIterations do
			connections[ RandomizedIndexes[i] ] = Signal:Connect(function()

			end)
		end

		local initialTime = os.clock()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		return os.clock() - initialTime
	end
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
