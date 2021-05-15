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

	local fire_id = #self + 1;
	self[fire_id] = table.pack(...);

	self._bindable:Fire(fire_id);
	self[fire_id] = nil;
end

function Signal.__call(self, _, ...)
	return self:Connect(...);
end

function Signal:Connect(handle)
	if not self._bindable then return end;

	return self._bindable.Event:Connect(function(fire_id)
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
		return handle(
			table.unpack(
				self[fire_id]
			)
		)
	end)
end

function Signal:Wait()
	if not self._bindable then return end;

	return table.unpack(
		self[
			self._bindable:Wait()
		]
	)
end

function Signal:Destroy()
	if not self._bindable then return end;

	self._bindable:Destroy();
	self._bindable = nil;
end

return Signal;
