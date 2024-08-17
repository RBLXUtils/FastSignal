--!optimize 2
--!nocheck
--!native

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

local NumberOfBenchmarks = 3
local Mode = "ConnectionStress" -- "NoConnections" / "ConnectionStress"

local function ConnectionsSetup(Event)
	if Mode ~= "ConnectionStress" then
		return
	end

	for _ = 1, 1000 do
		Event:Connect(function() end)
	end
end

local function singleBenchmark(Event)
	ConnectionsSetup(Event.Event or Event)

	local Fire = Event.Fire

	local initialTime = os.clock()
	for _ = 1, 1000 do
		Fire(Event)
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