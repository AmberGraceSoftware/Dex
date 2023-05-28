--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)
local State = require(script.Parent.State)

export type Stopwatch = Types.Stopwatch
export type Alpha = Types.Alpha

local Stopwatch = {}
Stopwatch.__index = {}
Stopwatch.__index.Start = BaseTimer.Start
Stopwatch.__index.Stop = BaseTimer.Stop
Stopwatch.__index.Pause = BaseTimer.Pause
Stopwatch.__index.EaseAlpha = BaseTimer.EaseAlpha
Stopwatch.__index.SliceAlpha = BaseTimer.SliceAlpha
Stopwatch.__index.Lerp = BaseTimer.Lerp
Stopwatch.__index.Current = Observable.__index.Current
Stopwatch.__index.Subscribe = Observable.__index.Subscribe
Stopwatch.__index.Map = Observable.__index.Map
Stopwatch.__index.Destroy = Observable.__index.Destroy
Stopwatch.__index._dectype = Observable.__index._dectype
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
function Stopwatch.new(maxDuration: number): Stopwatch
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = 0,
    })
    local function getCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return math.clamp(
                os.clock() - current.startClockTime,
                0,
                maxDuration
            )
        end
        return current.resumeAtElapsed
    end
    local function createUpdateStream(notifyUpdate: () -> ())
        local heartbeatConn = nil
        local function playStateChanged(current: typeof(playState:Current()))
            if current.playing then
                if not heartbeatConn then
                    heartbeatConn = RunService.Heartbeat:Connect(notifyUpdate)
                end
            else
                if heartbeatConn then
                    heartbeatConn:Disconnect()
                end
            end
            notifyUpdate()
        end
        local unsubscribe = playState:Subscribe(playStateChanged)
        playStateChanged(playState:Current())

        return function()
            unsubscribe()
            if heartbeatConn then
                heartbeatConn:Disconnect()
            end
        end
    end
    local self: Stopwatch = Observable.new(
        getCurrent,
        createUpdateStream
    ) :: any
    self._duration = maxDuration
    self._playState = playState
    setmetatable(self, BaseTimer)
    return self
end

return Stopwatch
