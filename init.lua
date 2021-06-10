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

local Signal = {};
Signal.__index = Signal;
Signal.ClassName = "Signal";

function Signal:__tostring()
	return string.format(
		"Signal %s",
		self.Name
	)
	--\\ Printing!
end

function Signal:__call(_, ...)
	return self:Connect(...);
end


function Signal:IsA(...)
	return ... == self.ClassName;
end

function Signal:IsActive()
	return self._bindable ~= nil;
end


function Signal.new(name)
	return setmetatable({
		_bindable = Instance.new('BindableEvent');
		Name = typeof(name) == 'string' and name or '';
	}, Signal)
end

function Signal:Fire(...)
	if not self._bindable then
		warn(
			("Cannot fire destroyed signal! %s"):format(self.Name)
		)
		return
	end;

	local fire_id;
	if ... ~= nil then
		fire_id = #self + 1;
		self[fire_id] = table.pack(...);
	end

	self._bindable:Fire(fire_id);
end

function Signal:Connect(handle)
	if not self._bindable then
		warn(
			("Cannot connect to destroyed signal! %s"):format(self.Name)
		)
		return
	end;
	assert(typeof(handle) == 'function', 'Attempt to connect failed: Passed value is not a function')

	return self._bindable.Event:Connect(function(fire_id)
		if (fire_id == nil) or (not self._bindable) then
			handle()
			return;
		end
		local args = self[fire_id]
		handle(
			table.unpack(
				args, 1, args.n 
			)
		)
	end)
end

function Signal:ConnectParallel(handle)
	if not self._bindable then
		warn(
			("Cannot connect to destroyed signal! %s"):format(self.Name)
		)
		return
	end;
	assert(typeof(handle) == 'function', 'Attempt to connect failed: Passed value is not a function')

	return self._bindable.Event:ConnectParallel(function(fire_id)
		if (fire_id == nil) or (not self._bindable) then
			handle()
			return;
		end
		local args = self[fire_id]
		handle(
			table.unpack(
				args, 1, args.n 
			)
		)
	end)
end

function Signal:Wait()
	if not self._bindable then
		warn(
			("Cannot :Wait to destroyed signal! %s"):format(self.Name)
		)
		return
	end;
	local fire_id = self._bindable.Event:Wait()
	if fire_id == nil then return end;
	if not self._bindable then return end;

	local args = self[fire_id]
	return table.unpack(
		args, 1, args.n
	);
end

function Signal:Destroy()
	if not self._bindable then
		warn(
			("Attempted to :Destroy an already destroyed signal! %s"):format(self.Name)
		)
		return
	end;

	self._bindable:Destroy();
	self._bindable = nil;

	for index, value in pairs(self) do
		if type(index) == 'number' then
			self[index] = nil;
		end
	end
end

return Signal;
