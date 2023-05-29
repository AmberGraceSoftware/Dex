--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)
local State = require(script.Parent.State)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type Stopwatch = Types.Stopwatch
type Alpha = Types.Alpha
type Observable<T> = Types.Observable<T>

local Stopwatch = {}
Stopwatch.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Stopwatch.__index :: any)[k] = v
end
-- Inherits BaseTimer
for k, v in BaseTimer :: any do
    (Stopwatch.__index :: any)[k] = v
end
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
    @return Observable<T> - The interpolated Observable.

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current elapsed time.
]]
function Stopwatch.__index.Lerp<T>(
    self: Stopwatch,
    startValue: T,
    endValue: T
): Observable<T>
    local interpolator = PolymorphicLerp(typeof(startValue))
    return MapObservable(
        self,
        function(current)
            local alpha = math.clamp(
                current / self._duration,
                0, 1
            )
            return interpolator(startValue, endValue, alpha)
        end
    ) :: any
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
