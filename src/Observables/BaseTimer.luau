--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type BaseTimer = Types.BaseTimer

local BaseTimer = {}
BaseTimer.__index = {}
BaseTimer.__index._dectype = "Observable"
BaseTimer.__index._decobservabletype = "BaseTimer"

--[[
    @return void

    Starts the timing-based Observable. The observable will update with new
    values every heartbeat in realtime until it is stopped.
]]
function BaseTimer.__index.Start(self: BaseTimer): ()
    error("Not implemented yet")
end

--[[
    @return void

    Stops the timing-based Observable.
]]
function BaseTimer.__index.Stop(self: BaseTimer): ()
    error("Not implemented yet")
end

--[[
    @return void

    Pauses the timing-based Observable.
]]
function BaseTimer.__index.Pause(self: BaseTimer): ()
    error("Not implemented yet")
end

--[[
    @return void

    Resumes the timing-based Observable.
]]
function BaseTimer.__index.Resume(self: BaseTimer): ()
    error("Not implemented yet")
end

BaseTimer.__index.Current = Observable.__index.Current
BaseTimer.__index.Subscribe = Observable.__index.Subscribe
BaseTimer.__index.Destroy = Observable.__index.Destroy

--[[
    @return Dec.BaseTimer - The new BaseTimer instance.

    Creates a new BaseTimer.
]]
function BaseTimer.new(): BaseTimer
    return setmetatable({
        _stepConnection = nil,
        _resumeAt = nil,
        _current = 0,
        _observerCount = 0,
    }, BaseTimer :: any)
end

return BaseTimer
