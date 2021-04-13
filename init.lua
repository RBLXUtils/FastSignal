local runService = game:GetService("RunService")

local c_yield = coroutine.yield
local c_running = coroutine.running
local c_resume = coroutine.resume
local c_create = coroutine.create
local os_clock = os.clock
local table_find = table.find
local table_insert = table.insert
local array_remove = function(Table, idx)
    local count = #Table
    
    Table[idx] = Table[count]
    Table[count] = nil
end

--\\ Yes, I micro-optimized it... Whatever.

local Signal = {};
Signal.__index = Signal;

local function runNoYield(func, ...)
    local yields = true;
    local args = ...
    local thread = coroutine.create(function()
        func(args)
        yields = false;
    end)
    coroutine.resume(thread)

    if yields then
        error("Function yielded!")
    end

    return yields
end

function Signal.new()
    return setmetatable({
        Active = true;
        _lastFired = os.clock();
        _functions = {};
    }, Signal)
end

function Signal:GetLastFired()
    return self._lastFired
end

function Signal:Connect(func)
    local conn = setmetatable({
        Connected = true;
        _func = func;
        _signal = self;
    }, Signal)

    table.insert(self._functions, conn)
    return conn
end

function Signal:Disconnect()
    if not self.Connected then return end

    local _signal = self._signal
    local _functions = _signal._functions

    local connIndex = table_find(_functions, self)
    if not connIndex then return end

    array_remove(_functions, connIndex)
    self.Connected = false
    self._signal = nil
end

function Signal:Fire(...)
    local _functions = self._functions
    local threads = {};
    for i = 1, #_functions do
        table_insert(threads, c_create(_functions[i]._func))
    end
    for i = 1, #threads do
        c_resume(threads[i], ...)
    end
    
end

function Signal:FireNoYield(...)
    local _functions = self._functions

    for i = 1, #_functions do
        runNoYield(_functions[i]._func, ...)
    end
end

function Signal:Wait()
    local thread = c_running()
    
    local conn;
    conn = self:Connect(function(...)
        conn:Disconnect()
        c_resume(thread, ...)
    end)
    
    return c_yield()
end

function Signal:Destroy()
    local _functions = self._functions
    local count = #_functions

    self.Active = false
    for i = 1, count do
        local conn = _functions[i]
        conn.Connected = false;
        conn._func = nil;
        conn._signal = nil;
    end
    table.clear(_functions)
end

return Signal
