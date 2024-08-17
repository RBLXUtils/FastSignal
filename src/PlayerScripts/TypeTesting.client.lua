--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptSignal = require(ReplicatedStorage.FastSignal)

local Event = ScriptSignal.new()

local function TypeTest(arg: string)
	return arg
end

Event:Connect(function()
	
end)