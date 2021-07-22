--[[

	Signal:

		Functions:

			Signal.new()
				Returns: ScriptSignal
				Parameters: Signal Name: string (optional)

				Description:
					\\ Creates a new ScriptSignal object.
					\\ Signal Name is used for printing, it's not needed.

	ScriptSignal:

		Properties:

			Signal.ClassName (read-only)
				\\ Always "Signal".

			Signal.Name
				\\ The name you give it, if you do, on Signal.new

		Functions:

			ScriptSignal:IsActive()

				Returns: boolean
				Parameters: nil

				Description:
					\\ Returns whether a ScriptSignal is active or not.

			ScriptSignal:Fire(...)

				Returns: nil
				Parameters: any

				Description:
					\\ Fires a ScriptSignal with any arguments.

			ScriptSignal:Connect()

				Returns: RBXScriptConnection
				Parameters: function

				Description:
					\\ Connects a function to a ScriptSignal.

			ScriptSignal:ConnectParallel()

				Returns: RBXScriptConnection
				Parameters: function

				Description:
					\\ Connects a function to a ScriptSignal. (multi-threading)

			ScriptSignal:Wait()

				Returns: any
				Parameters: nil

				Description:
					\\ Yields until the Signal it belongs to is fired.
					\\ Will return the arguments it was fired with.

			ScriptSignal:Destroy()

				Returns: nil
				Parameters: nil

				Description:
					\\ Destroys a ScriptSignal, all connections are then disconnected.

		RBXScriptConnection:

			Parameters:

				RBXScriptConnection.Connected: boolean
					--\\ If true:
								RBXScriptConnection is connected.
						 Else if false:
						 		RBXScriptConnection is disconnected.

			Functions:

				RBXScriptConnection:Disconnect()

					Parameters: nil
					Returns: nil

					Description:
						\\ Disconnects a connection.

		---

		"Quirks":

			\\ If a Signal is inside a table, you can :Connect to it by calling it as a function.
			\\ Example:

				local t = {}
				t.Signal = Signal.new()
				t:Signal(function()
					print('Signal Fired!')
				end)

			\\ This makes it easier for developers to simply have functions like 'ListenToChange'
			\\ which you won't need extra keys for it anymore.

			--


			Supports :Fire 'ing inside connections.

			Supports multi-threading with :ConnectParallel
				 ^ Beta! (should be working just fine now!)
]]

local HttpService = game:GetService("HttpService")

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

local DEBUG_MODE = true -- is :__tostring() deactivated
local FAST_MODE = false
	--\\ With FAST_MODE on, the arguments are stored under an increasing index.
	-- Basically, that means that :Fire is faster, but UN SAFE.
	-- As long as the Signals you're creating are only fired on one thread,
	-- Or even if they're just not supposed to be fired by another dev, then you're safe to enable this.
	-- Overall, this should only be an issue if there's multiple threads firing at the same time.
	-- Also note this speed advantage is not gonna impact you for the most part at all.

function Signal:__call(_, func)
	return self:Connect(func)
end

function Signal:__tostring()
	return "Signal ".. self.Name
end

if DEBUG_MODE then
	Signal.__tostring = nil
end


local function GenerateUniqueID(self)
	if FAST_MODE then
		self._fireCounter += 1
		return self._fireCounter
	end

	local _args = self._args

	local id = HttpService:GenerateGUID()
	while _args[id] do
		id = HttpService:GenerateGUID()
	end

	return id
end

function Signal:IsA(...)
	return self.ClassName == ...
end

function Signal:IsActive()
	return self._active == true
end

function Signal.new(name)
	local self = {
		_active = true,
		Name = typeof(name) == 'string' and name or "",
		_bindable = Instance.new("BindableEvent"),
		_args = table.create(2)
	}

	setmetatable(self, Signal)

	self._bindable.Event:Connect(function(fire_id)
		if not fire_id then
			return
		end

		self._args[fire_id] = nil

		if (not self._bindable) and (not next(self._args)) then
			self._args = nil
		end
	end)

	return self
end

function Signal:Fire(...)
	if not self:IsActive() then
		warn("You cannot :Fire a destroyed Signal. -".. self.Name)
		return
	end

	local args = table.pack(...)
	local fire_id
	if args.n ~= 0 then
		fire_id = GenerateUniqueID(self)
		self._args[fire_id] = args
	end

	self._bindable:Fire(fire_id)
end


local function Connect(self, func, isParallel)
	if not self:IsActive() then
		warn("You cannot connect to a destroyed Signal. -".. self.Name)
		return;
	end

	assert(
		typeof(func) == 'function',
		":Connect can only connect a function. -".. self.Name
	)

	self._bindable.Event:Connect(function(fire_id)
		if fire_id then
			local args = self._args[fire_id]

			if isParallel then
				task.desynchronize()
			end

			if args then
				func(
					table.unpack(args, 1, args.n)
				)
				return
			end

			error("Arguments missing.")
		end

		if isParallel then
			task.desynchronize()
		end

		func()
	end)
end

function Signal:Connect(func)
	return Connect(self, func, false)
end

function Signal:ConnectParallel(func)
	return Connect(self, func, true)
end

function Signal:Wait()
	if not self:IsActive() then
		warn("You cannot :Wait to an destroyed Signal. -".. self.Name)
		return
	end

	local fire_id = self._bindable.Event:Wait()

	if fire_id then
		local args = self._args[fire_id]

		if args then
			return table.unpack(args, 1, args.n)
		end

		error("Arguments missing.")
	end
end

function Signal:Destroy()
	if not self:IsActive() then
		warn("You cannot destroy an already destroyed Signal. -".. self.Name)
		return;
	end

	self._active = false

	if self._bindable then
		self._bindable:Destroy()
		self._bindable = nil

		if not next(self._args) then
			self._args = nil
		end
	end
end

return Signal
