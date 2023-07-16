--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)
local State = require(script.Parent.State)
local Observable = require(script.Parent.Observable)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type Timer = Types.Timer
type Alpha = Types.Alpha
type Observable<T> = Types.Observable<T>

--[=[
    @class Timer
    @tag Observable

    #### Inherits [Observable]

    Observable which counts down from a max value in realtime whenever played
    via [Timer:Start].

    Includes utility methods for mapping this "remaining time" value into more
    complex animationed sequences.

    ## Constructor
    
    ---
    
    ### Dec.Timer
    ```lua
    Dec.Timer(duration number) -> Tmier
    ```

    Creates a new [Timer] Observable, the value of which decreases in realtime
    after [Timer:Start] is called.

    Timers can safely be garbage collected while dereferenced, unsubscribed,
    and unused by a VirtualInstance.
]=]
local Timer = {}
-- Inherits Timer metamethods
for k, v in Timer :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Timer :: any)[k] = v
end
Timer.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Timer.__index :: any)[k] = v
end
-- Inherits BaseTimer
for k, v in BaseTimer :: any do
    (Timer.__index :: any)[k] = v
end
Timer.__index._decobservabletype = "Timer"

--[=[
    @method Alpha
    @within Timer
    @return Alpha

    Derives an Alpha observable object that maps the current remaining time from
    0 (start) to 1 (finish)
]=]
function Timer.__index.Alpha(self: Timer): Alpha
    return Alpha.new(self, self._duration, 0)
end

--[=[
    @method SetDuration
    @within Timer
    @param duration number

    Sets the duration of the Timer.
]=]
function Timer.__index.SetDuration(self: Timer, duration: number): ()
    self._duration = duration
end

--[=[
    @method Lerp
    @within Timer
    @return Observable<T>

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current remaining time.
]=]
function Timer.__index.Lerp<T>(
    self: Timer,
    startValue: T,
    endValue: T
): Observable<T>
    local interpolator = PolymorphicLerp(typeof(startValue))
    return MapObservable(self)(function(current)
        local alpha = 1 - math.clamp(
            current / self._duration,
            0, 1
        )
        return interpolator(startValue, endValue, alpha)
    end) :: any
end

function Timer.__index.SetTimePosition(self: Timer, pos: number)
    BaseTimer.SetTimePosition(self,
        math.clamp(self._duration - pos, 0, self._duration))
end


--[=[
    @function Timer
    @within Dec
    @param duration number
    @return Timer

    Creates a new Timer Observable, which simulates in realtime while
    subscribed.
]=]
function Timer.new(duration: number): Timer
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
    local function getCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return math.clamp(
                duration - (os.clock() - current.startClockTime),
                0,
                duration
            )
        end
        return math.clamp(duration - current.resumeAtTime, 0, duration)
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
    local self: Timer = Observable.new(
        getCurrent,
        createUpdateStream
    ) :: any
    self._duration = duration
    self._playState = playState
    setmetatable(self, Timer)
    return self
end

return Timer