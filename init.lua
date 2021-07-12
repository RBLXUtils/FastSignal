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
				 ^ Beta!
]]

local HttpService = game:GetService("HttpService")

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"



function Signal:__call(_, ...)
	return self:Connect(...)
end

function Signal:__tostring()
	return "Signal ".. self.Name
end

local function GenerateUniqueID(self)
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

function Signal.new(name)
	local self = setmetatable({
		Name = typeof(name) == 'string' and name or "",
		_bindable = Instance.new("BindableEvent"),
		_args = {}
	}, Signal)

	--\\ Thanks Quenty for the info,
	--   Events are fired from the most recently connected, to the
	--   last connected one. Meaning we can finally do clean up of arguments!
	
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
	if not self._bindable then
		warn("You cannot :Fire a destroyed Signal. ".. self.Name)
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


function Signal:Connect(func)
	if not self._bindable then
		warn("You cannot connect to a destroyed Signal. ".. self.Name)
		return;
	end

	assert(
		typeof(func) == 'function',
		":Connect can only connect a function. ".. self.Name
	)


	self._bindable.Event:Connect(function(fire_id)
		if fire_id then
			local args = self._args[fire_id]

			if args then
				func(
					table.unpack(args, 1, args.n)
				)
				return
			end

			error("Arguments missing.")
		end

		func()
	end)
end

function Signal:ConnectParallel(func)
	if not self._bindable then
		warn("You cannot connect to a destroyed Signal. ".. self.Name)
		return;
	end

	assert(
		typeof(func) == 'function',
		":ConnectParallel can only connect a function. ".. self.Name
	)


	self._bindable.Event:ConnectParallel(function(fire_id)
		if fire_id then
			local args = self._args[fire_id]

			if args then
				func(
					table.unpack(args, 1, args.n)
				)
				return
			end

			error("Arguments missing.")
		end

		func()
	end)
end

function Signal:Wait()
	if not self._bindable then
		warn("You cannot :Wait to an destroyed Signal. ".. self.Name)
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
	if not self._bindable then
		warn("You cannot destroy an already destroyed Signal. ".. self.Name)
		return;
	end

	self._bindable:Destroy()
	self._bindable = nil

	if not next(self._args) then
		self._args = nil
	end
end

return Signal
