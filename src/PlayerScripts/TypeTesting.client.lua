--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScriptSignal = require(ReplicatedStorage.FastSignal.Immediate)

local AutomaticType do
	local Event: ScriptSignal.ScriptSignal<{number}> = ScriptSignal.new()

	Event:Connect(function(array)
		array[1] ..= "what"
		array[2] += 5
	end)
end

local GenericTypes do
	local Event: ScriptSignal.ScriptSignal<{
		Member1: string,
		Member2: number
	}> = ScriptSignal.new()

	-- Roblox LSP seems to complain, IG they don't support generic types?
	Event:Connect(function(info)
		info.Member1 += 10 -- Should complain
		info.Member2 ..= "what" -- Should complain
	end)
end