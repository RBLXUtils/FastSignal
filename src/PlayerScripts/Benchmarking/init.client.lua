--!optimize 2
--!nocheck
--!native

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SignalTypes: {
	[string]: {
		new: () -> RBXScriptSignal,
		[any]: any
	}
} = {
	GoodSignal = require(ReplicatedStorage.GoodSignal),
	FastSignal = require(ReplicatedStorage.FastSignal),
	RBXScriptSignal = require(ReplicatedStorage.RBXScriptSignal),
	LemonSignal = require(ReplicatedStorage.LemonSignal)
}

local Benchmarks: {ModuleScript} = {} do
	local children = script:GetChildren()

	for _, child in ipairs(children) do
		if child:IsA("ModuleScript") then
			table.insert(Benchmarks, child)
		end
	end
end

local results: {
	[string]: { -- Benchmark
		[string]: number -- SignalClass: result
	}
} = {}
for _, benchmark in ipairs(Benchmarks) do
	local benchmarkName = benchmark.Name
	benchmark = require(benchmark) :: (RBXScriptSignal) -> (number)

	local benchmarkResults = {}
	results[benchmarkName] = benchmarkResults

	for signalName, signalClass in pairs(SignalTypes) do
		task.wait(1)
		benchmarkResults[signalName] = benchmark(signalClass.new())
	end
end

local resultString do
	resultString = "Benchmark Results:\n"

	local indentation = {}

	local function getIndent()
		return table.concat(indentation)
	end

	local function indent()
		table.insert(indentation, "	")
	end

	local function unindent()
		indentation[#indentation] = nil
	end
	
	for benchmark, signalResult in pairs(results) do
		indent()
		local benchmarkSection = getIndent().. benchmark.. ":\n"
		for signalName, result in pairs(signalResult) do
			indent()
			benchmarkSection ..= getIndent().. signalName.. ": ".. result.. "\n"
			unindent()
		end

		resultString ..= benchmarkSection
		unindent()
	end
end

print(resultString)