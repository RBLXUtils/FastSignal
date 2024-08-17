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