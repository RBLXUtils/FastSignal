local HttpService = game:GetService('HttpService');

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

	return self._event:Connect(function(fireId)
		func(table.unpack(self[fireId]));
	end)
end

function Signal:ConnectParallel(func)
	if not self.Active then return end;

	return self._event:ConnectParallel(function(fireId)
		func(table.unpack(self[fireId]));
	end)
end

function Signal:Fire(...)
	if not self.Active then return end;

	local fireId = os.clock();
	if self[fireId] then return self:Fire(...) end;

	self[fireId] = table.pack(...);
	self._bindableEvent:Fire(fireId);
	self[fireId] = nil;
end

function Signal:Wait()
	if not self.Active then return end;

	local fireId = self._event:Wait();
	if not fireId then return end;

	return table.unpack(self[fireId]);
end

function Signal:Destroy()
	if not self.Active then return end;

	self.Active = false;
	self._event = nil;
	self._bindableEvent:Destroy();
	self._bindableEvent = nil;
end

return Signal;
