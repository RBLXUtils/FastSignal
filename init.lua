local Signal = {};
Signal.__index = Signal;
Signal.ClassName = 'Signal';

function Signal.__call(self, _, ...)
	return self:Connect(...);
end

function Signal.new()
	local self = setmetatable({
		_bindableEvent = Instance.new('BindableEvent');
		Active = true;
	}, Signal);
	self._event = self._bindableEvent.Event;
	return self;
end

function Signal:Connect(func)
	if not self.Active then return end;

	return self._event:Connect(function(...)
		func(table.unpack(...));
	end)
end

function Signal:ConnectParallel(func)
	if not self.Active then return end;

	return self._event:ConnectParallel(function(...)
		func(table.unpack(...));
	end)
end

function Signal:Fire(...)
	if not self.Active then return end;

	self._bindableEvent:Fire(table.pack(...));
end

function Signal:Wait()
	if not self.Active then return end;

	return table.unpack(self._event:Wait());
end

function Signal:Destroy()
	if not self.Active then return end;

	self.Active = false;
	self._event = nil;
	self._bindableEvent:Destroy();
	self._bindableEvent = nil;
end

return Signal;
