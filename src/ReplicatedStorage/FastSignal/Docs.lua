--[[
	Meant to hold docs. Makes it easier to mess with them individually.
]]

if true then
	error("This is not supposed to run!")
end

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

-- Methods:

--[=[
	A class which holds data and methods for ScriptSignals.

	@class ScriptSignal
]=]
local ScriptSignal = {}
ScriptSignal.__index = ScriptSignal

--[=[
	A class which holds data and methods for ScriptConnections.

	@class ScriptConnection
]=]
local ScriptConnection = {}
ScriptConnection.__index = ScriptConnection

--[=[
	A boolean which determines if a ScriptConnection is active or not.

	@prop Connected boolean
	@within ScriptConnection

	@readonly
]=]

--[=[
	Creates a ScriptSignal object.

	@return ScriptSignal
]=]
function ScriptSignal.new()
	return {}
end

--[=[
	Returns a boolean determining if the object is a ScriptSignal.

	```lua
	local janitor = Janitor.new()
	local signal = ScriptSignal.new()

	ScriptSignal.Is(signal) -> true
	ScriptSignal.Is(janitor) -> false
	```

	@param object any
	@return boolean
]=]
function ScriptSignal.Is(object)
	return true
end

--[=[
	Returns a boolean which determines if a ScriptSignal object is active.

	```lua
	ScriptSignal:IsActive() -> true
	ScriptSignal:Destroy()
	ScriptSignal:IsActive() -> false
	```

	@return boolean
]=]
function ScriptSignal:IsActive()
	return true
end

--[=[
	Connects a handler to a ScriptSignal object.

	```lua
	ScriptSignal:Connect(function(text)
		print(text)
	end)

	ScriptSignal:Fire("Something")
	ScriptSignal:Fire("Something else")

	-- "Something" and then "Something else" are printed
	```

	@param handler (...: any) -> ()
	@return ScriptConnection
]=]
function ScriptSignal:Connect(handler)

end

--[=[
	Connects a handler to a ScriptSignal object, but only allows that
	connection to run once. Any `:Fire` calls called afterwards won't trigger anything.

	```lua
	ScriptSignal:Once(function()
		print("Connection fired")
	end)

	ScriptSignal:Fire()
	ScriptSignal:Fire()

	-- "Connection fired" is only fired once
	```

	@param handler (...: any) -> ()
	@return ScriptConnection
]=]
function ScriptSignal:Once(handler)

end

--[=[
	Yields the thread until a `:Fire` call occurs, returns what the signal was fired with.

	```lua
	task.spawn(function()
		print(
			ScriptSignal:Wait()
		)
	end)

	ScriptSignal:Fire("Arg", nil, 1, 2, 3, nil)
	-- "Arg", nil, 1, 2, 3, nil are printed
	```

	@yields
	@return ...any
]=]
function ScriptSignal:Wait()
	
end

--[=[
	Fires a ScriptSignal object with the arguments passed.

	```lua
	ScriptSignal:Connect(function(text)
		print(text)
	end)

	ScriptSignal:Fire("Some Text...")

	-- "Some Text..." is printed twice
	```

	@param ... any
]=]
function ScriptSignal:Fire(...)
	
end

--[=[
	Disconnects all connections from a ScriptSignal object without making it unusable.

	```lua
	local connection = ScriptSignal:Connect(function() end)

	connection.Connected -> true
	ScriptSignal:DisconnectAll()
	connection.Connected -> false
	```
]=]
function ScriptSignal:DisconnectAll()
	
end

--[=[
	Destroys a ScriptSignal object, disconnecting all connections and making it unusable.

	```lua
	ScriptSignal:Destroy()

	local connection = ScriptSignal:Connect(function() end)
	connection.Connected -> false
	```
]=]
function ScriptSignal:Destroy()
	
end

--[=[
	Disconnects a connection, any `:Fire` calls from now on will not
	invoke this connection's handler.

	```lua
	local connection = ScriptSignal:Connect(function() end)

	connection.Connected -> true
	connection:Disconnect()
	connection.Connected -> false
	```
]=]
function ScriptConnection:Disconnect()
	
end

-- Stricter type
local returnType = {}

function returnType.new<T...>(): ScriptSignal<T...>
	return ScriptSignal.new()
end

function returnType.Is(any): boolean
	return true
end

return returnType