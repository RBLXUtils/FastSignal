--!optimize 2
--!native

export type ScriptSignal<T...> = {
	IsActive: (self: ScriptSignal<T...>) -> boolean,
	Fire: (self: ScriptSignal<T...>, T...) -> (),
	Connect: (self: ScriptSignal<T...>, callback: (T...) -> ()) -> ScriptConnection,
	Once: (self: ScriptSignal<T...>, callback: (T...) -> ()) -> ScriptConnection,
	DisconnectAll: (self: ScriptSignal<T...>) -> (),
	Destroy: (self: ScriptSignal<T...>) -> (),
	Wait: (self: ScriptSignal<T...>) -> T...,
}
export type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
	Connected: boolean,
}

-- Legacy type. Do not use in newer work.
export type Class = ScriptSignal<...any>

local MainScriptSignal = require(script.Parent.Deferred)

local ScriptSignal = {} do
	for methodName, method in pairs(MainScriptSignal) do
		ScriptSignal[methodName] = method
	end
	ScriptSignal.__index = ScriptSignal
end

local FreeThread: thread? = nil
local function RunHandlerInFreeThread(handler, ...)
	local thread = FreeThread :: thread
	FreeThread = nil

	handler(...)

	FreeThread = thread
end

local function CreateFreeThread()
	FreeThread = coroutine.running()

	while true do
		RunHandlerInFreeThread( coroutine.yield() )
	end
end

function ScriptSignal.new()
	return setmetatable({
		_active = true,
		_head = nil
	}, ScriptSignal)
end

function ScriptSignal.Is(object)
	return typeof(object) == 'table'
		and getmetatable(object) == ScriptSignal
end

function ScriptSignal:Fire(...)
	local node = self._head
	while node ~= nil do
		if node._connection ~= nil then
			if FreeThread == nil then
				task.spawn(CreateFreeThread)
			end

			task.spawn(
				FreeThread :: thread,
				node._handler, ...
			)
		end

		node = node._next
	end
end

return ScriptSignal :: typeof( require(script.Parent.Docs) )