local Signal = {};
Signal.__index = Signal;
Signal.ClassName = 'Signal';

function Signal:IsA(...)
	return ... == self.ClassName;
end

function Signal:IsActive()
	return self._bindable ~= nil;
end

function Signal.new()
	return setmetatable({
		_bindable = Instance.new('BindableEvent')
	}, Signal)
end

function Signal:Fire(...)
	if not self._bindable then return end;

	local fire_id;
	if ... ~= nil then
		fire_id = #self + 1;
		self[fire_id] = table.pack(...);
	end

	self._bindable:Fire(fire_id);

	if ... == nil then return end;
	self[fire_id] = nil;
end

function Signal.__call(self, _, ...)
	return self:Connect(...);
end

function Signal:Connect(handle)
	if not self._bindable then return end;

	return self._bindable.Event:Connect(function(fire_id)
		if fire_id == nil then
			return handle()
		end
		return handle(
			table.unpack(
				self[fire_id]
			)
		)
	end)
end

function Signal:ConnectParallel(handle)
	if not self._bindable then return end;

	return self._bindable.Event:ConnectParallel(function(fire_id)
		if fire_id == nil then
			return handle()
		end
		return handle(
			table.unpack(
				self[fire_id]
			)
		)
	end)
end

function Signal:Wait()
	if not self._bindable then return end;

	local fire_id = self._bindable.Event:Wait()
	if fire_id == nil then return end;
	
	return table.unpack(
		self[fire_id]
	);
end

function Signal:Destroy()
	if not self._bindable then return end;

	self._bindable:Destroy();
	self._bindable = nil;
end

return Signal;
