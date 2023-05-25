--!strict
local Types = require(script.Parent.Parent.Types)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)

export type Stopwatch = Types.Stopwatch
export type Alpha = Types.Alpha

local Stopwatch = {}
Stopwatch.__index = {}
Stopwatch.__index.Start = BaseTimer.__index.Start
Stopwatch.__index.Stop = BaseTimer.__index.Stop
Stopwatch.__index.Pause = BaseTimer.__index.Pause
Stopwatch.__index.Current = BaseTimer.__index.Current
Stopwatch.__index.Subscribe = BaseTimer.__index.Subscribe
Stopwatch.__index.Destroy = BaseTimer.__index.Destroy
Stopwatch.__index._dectype = BaseTimer.__index._dectype
Stopwatch.__index._decobservabletype = "Stopwatch"

--[[
    @param endElapsedTime: number - The end elapsed time.
    @return Dec.Alpha - An Alpha observable object that maps the elapsed time from 0 (start) to 1 (end).
    
    Derives an Alpha observable object based on the current elapsed time of this
    stopwatch.
]]
function Stopwatch.__index.Alpha(
    self: Stopwatch,
    param1: number,
    param2: number?
): Alpha
    local startElapsedTime = param2 or 0
    local endElapsedTime = if param2 then param2 else param1
    return Alpha.new(self, startElapsedTime, endElapsedTime)
end

--[[
    @return Dec.Stopwatch - The new Stopwatch observable.

    Creates a new Stopwatch observable.
]]
function Stopwatch.new(): Stopwatch
    local self: Stopwatch = BaseTimer.new() :: any
    setmetatable(self, Stopwatch)
    return self
end

return Stopwatch
