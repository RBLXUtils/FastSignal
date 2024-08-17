-- Simple wrapper for RBXScriptSignals. Not recommended for use
-- Does not include fixes for firing args etc
-- Only exists for compatibility with benchmarking script

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_bindable = Instance.new("BindableEvent")
	}, Signal)
end

function Signal:Connect(callback)
	return self._bindable.Event:Connect(callback)
end

function Signal:Wait()
	return self._bindable.Event:Wait()
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Destroy()
	self._bindable:Destroy()
end

return Signal