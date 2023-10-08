--!strict
local RunService = game:GetService("RunService")
local Observable = require(script.Parent.Observable)

--[=[
    @prop Clock
    @within Dec

    Observable number that derives its value from the current time in seconds
    in UTC (i.e. the value returned by `os.time()`)

    While subscribed, `Dec.Clock` automatically updates its value whenever the
    value of `os.time()` changes.
]=]

local Clock = Observable.new(
    os.time,
    function(notifyUpdate)
        local lastTime = os.time()
        local conn = RunService.Heartbeat:Connect(function()
            local nextTime = os.time()
            if nextTime ~= lastTime then
                lastTime = nextTime
                notifyUpdate()
            end
        end)
        return function()
            conn:Disconnect()
        end
    end
)

return Clock