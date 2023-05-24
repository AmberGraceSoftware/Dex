--!strict
local Types = require(script.Parent.Parent.Types)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)

export type Timer = Types.Timer
export type Alpha = Types.Alpha

local Timer = {}
Timer.__index = {}
Timer.__index._dectype = "Observable"
Timer.__index._decobservabletype = "Timer"

--[[
    @return Dec.Alpha

    Derives an Alpha observable object that maps the duration from 0 (start) to
    1 (finish)
]]
function Timer.__index.Alpha(self: Timer): Alpha
    error("Not implemented yet")
end

--[[
    @param duration: number
    @return void

    Sets the duration of the timer.
]]
function Timer.__index.SetDuration(self: Timer, duration: number): ()
    error("Not implemented yet")
end

Timer.__index.Start = BaseTimer.__index.Start
Timer.__index.Stop = BaseTimer.__index.Stop
Timer.__index.Pause = BaseTimer.__index.Pause
Timer.__index.Resume = BaseTimer.__index.Resume

function Timer.__index.Current(self: Timer): number
    local baseCurrent = BaseTimer.__index.Current(self)
    return math.max(self._duration - baseCurrent, 0)
end

Timer.__index.Subscribe = BaseTimer.__index.Subscribe
Timer.__index.Destroy = BaseTimer.__index.Destroy

--[[
    @param duration: number
    @return timer: Dec.Timer

    Creates a new Timer observable with the given duration.
]]
function Timer.new(duration: number): Timer
    return setmetatable({
        _duration = duration,
        _stepConnection = nil,
        _resumeAt = nil,
        _current = 0,
        _observerCount = 0,
    }, Timer :: any)
end

return Timer