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

--[[
local function runNoYield(func, ...)
    local args = ...;

    local toReturn;

    local thread = c_create(function()
        toReturn = table.pack(func(arguments))
    end)
    c_resume(thread)
    
    local status = coroutine.status(thread)
    if status ~= "dead" then
        error("Function yielded! Not allowed!")
        --\\ can't figure out a way of stopping the function completely as of the moment.
    end
    return table.unpack(toReturn)
end
]]

function Signal.new()
    return setmetatable({
        Active = true;
        _lastFired = os.clock();
        _functions = {};
    }, Signal)
end

function Signal.GetLastFired(self)
    return self._lastFired
end

function Signal.Connect(self, func)
    local conn = setmetatable({
        Connected = true;
        _func = func;
        _signal = self;
    }, Signal)

    table_insert(self._functions, conn)
    return conn
end

function Signal.Disconnect(self)
    if not self.Connected then return end

    local _signal = self._signal
    local _functions = _signal._functions
    
    self.Connected = false;
    self._signal = nil;
    self._func = nil;

    local connIndex = table_find(_functions, self)
    if not connIndex then return end;

    array_remove(_functions, connIndex)  
end

function Signal.Fire(self, ...)
    local _functions = self._functions
    local threads = {};
    for i = 1, #_functions do
        table_insert(threads, c_create(_functions[i]._func))
    end
    for i = 1, #threads do
        c_resume(threads[i], ...)
    end
    table.clear(threads)
end

--[[
function Signal.FireNoYield(self, ...)
    local _functions = self._functions

    for i = 1, #_functions do
        runNoYield(_functions[i], ...)
    end
    --\\ deprecated!
end
]]

function Signal.Wait(self)
    local thread = c_running()
    
    local conn;
    conn = self:Connect(function(...)
        conn:Disconnect()
        c_resume(thread, ...)
    end)
    
    return c_yield()
end

function Signal.Destroy(self)
    local _functions = self._functions

    self.Active = false
    for i = 1, #_functions do
        local conn = _functions[i]
        conn.Connected = false;
        conn._func = nil;
        conn._signal = nil;
    end
    table.clear(_functions)
end

return Signal
