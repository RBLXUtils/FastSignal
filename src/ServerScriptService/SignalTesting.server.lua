local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.FastSignal)

local IsDeferred do
	IsDeferred = false

	local Event = Signal.new()

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

	local Event = Signal.new()
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