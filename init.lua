local RunService = game:GetService('RunService');

local Signal = { };
Signal.__index = Signal;

function Signal.Disconnect(self)
	table.remove(self._event, table.find(self._event, self._callback));
end;

local Event = { };
Event.__index = Event;

function Event.Connect(self, callback)
	table.insert(self, #self + 1, callback);
	
	return setmetatable({ _event = self, _callback = callback }, Signal);
end;

function Event.Fire(self, ...)
	for index = 1, #self do
		local thread = coroutine.create(self[index]);
		coroutine.resume(thread, ...);
	end;
	
	self._lastFire = os.clock();
end;

function Event.Wait(self)
	local init = os.clock();
	
	repeat
		local delta = os.clock() - self._lastFire;
		local beat = (os.clock() - init) + RunService.Heartbeat:Wait();
	until delta < beat;
	
	return os.clock() - init;
end;

function Event.new()
	return setmetatable({ _lastFire = 0; }, Event);
end;
