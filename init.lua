local runService = game:GetService("RunService")

type Function = () -> any
type Connection = {
    new: () -> Connection,
    Connect: (Connection, Function) -> Connection,
    Disconnect: (Connection),
    Wait: (Connection) -> number,
    _function: Function,
    Connected: boolean,
}
type selfSignal = {
    new: () -> selfSignal,
    Destroy: () -> any,
    Fire: (Function)
    
}

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

local function doesYield(func, ...): boolean
    local packed = table.pack(...)
    local completed = false
    
    local thread: thread = coroutine.create(function()
        func(table.unpack(packed))
        completed = true
    end)
    
    coroutine.resume(thread)
    return not completed
end

function Signal.new(): selfSignal
    local self = setmetatable({
        Active = true;
    }, Signal)

    return self
end

function Signal:Connect(fun: Function)
    if not self.Active then return end
    local conn = setmetatable({
        Connected = true;
        _function = fun;
        _fromSignal = self
    }, Signal)
    table.insert(self, conn)
    return conn
end

function Signal:IsA(...)
    return Signal.ClassName == ...
end

function Signal:Destroy()
    self.Active = false
    for index = 1, #self do
        self[index]._function = nil
        self[index].Connected = false
        self[index]._fromSignal = nil
        self[index] = nil
    end
end

function Signal:Fire(...)
   for index = 1, #self do
		if self[index].Connected then
			local thread = coroutine.create(self[index]._function)
			coroutine.resume(thread, ...)
		end
	end
end

function Signal:FireNoYield(...)
    for index = 1, #self do
        if self[index].Connected then
            assert(not doesYield(self[index]._function), "A connection yielded! :FireNoYield() doesn't allow that!")
        end
    end
end

function Signal:Wait(): any
    local thread = coroutine.running()
    
    local conn
    conn = self:Connect(function(...)
        conn:Disconnect()
        coroutine.resume(thread, ...)
    end)

    return coroutine.yield()
end

function Signal:Disconnect()
	if not self._function or not self.Connected then return end
	local index = table.find(self._fromSignal, self)
	if not index then return end
	
	self._function = nil
	self.Connected = false
	table.remove(self._fromSignal, index)
end

return Signal
