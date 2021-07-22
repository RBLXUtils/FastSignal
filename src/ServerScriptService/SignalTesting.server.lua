local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Signal)

local Event = Signal.new("CoolEvent")
print(Event)

Event:Connect(function(...)
    print(Event, ...)
end)

task.spawn(function()
    print("Wait", Event:Wait())
end)

Event:Fire("what,", "... is going on?")

Event:Destroy()
print(Event)

Event:Connect()
