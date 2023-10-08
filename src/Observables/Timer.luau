--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local BaseTimer = require(script.Parent.BaseTimer)
local State = require(script.Parent.State)
local Observable = require(script.Parent.Observable)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type Timer = Types.Timer
type TimerProps = Types.TimerProps
type Observable<T> = Types.Observable<T>

--[=[
    @class Timer
    @tag Observable

    #### Inherits [Observable]

    Observable which counts down from a max value in realtime whenever played
    via [Timer:Play].

    Includes utility methods for mapping this "remaining time" value into more
    complex animationed sequences.

    ## Constructor
    
    ---
    
    ### Dec.Timer
    ```lua
    Dec.Timer({
        duration: number,
        isPlaying: CanBeObservable<boolean>?,
        playOnChange: Observable<any>?,
    }) -> Timer
    ```

    Creates a new [Timer] Observable, the value of which decreases in realtime
    after [Timer:Play] is called.

    #### Props:

    `duration` is a required prop that specifies the initial time of the timer.

    `isPlaying` specifies that timer should play and stop depending on an
    observable boolean value. If set to `true`, the timer will immediately start
    playing.

    `playOnChange` specifies that the timer should restart whenever an input
    observable changes.

    ----

    Timers can safely be garbage collected while dereferenced, unsubscribed,
    and unused by a VirtualInstance.

    :::info
    Timers must currently be ***Subscribed*** or ***Mounted*** to exhibit
    expected behavior. This is a requirement for all realtime-simulated
    observables which enables safe garbage collection when writing Dec
    components.
    :::

    Usage Example:
    ```lua
    local timer = Dec.Timer({
        duration = 10,
        isPlaying = true,
    })
    local frame = Dec.New("Frame")({
        -- Opaque for 5 seconds, then fades to Transparent over 5 seconds:
        BackgroundTransparency = timer:Alpha(5, 0),
    })
    ```
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

--[=[
    @method Alpha
    @within Timer
    @param startTime number
    @param endTime number
    @return Alpha

    Derives an observble number that maps the remaining time from from 0 at the
    provided start time, and 1 at the provided end time.
]=]
function Timer.__index.Alpha(
    self: Timer,
    startTime: number,
    endTime: number
): Observable<number>
    local duration = endTime - startTime
    if duration == 0 then
       return State.new(0)
    end
    return  MapObservable(self)(function(current)
        return math.clamp(
            (current - startTime) / duration,
            0, 1
        )
    end)
end

function Timer.__index.SetTimePosition(self: Timer, pos: number)
    BaseTimer.SetTimePosition(self,
        math.clamp(self._duration - pos, 0, self._duration))
end

--[=[
    @interface TimerProps
    @within Timer
    @field duration number
    @field isPlaying CanBeObservable<boolean>?,
    @field playOnChange Observable<any>?,

    Type that specifies the props for constructing a [Timer] observable (via
    [Dec.Timer])

    `duration` is a required prop that specifies the initial time of the timer.

    `isPlaying` specifies that timer should play and stop depending on an
    observable boolean value. If set to `true`, the timer will immediately start
    playing.

    `playOnChange` specifies that the timer should restart whenever an input
    observable changes.
]=]

--[=[
    @function Timer
    @within Dec
    @param props TimerProps
    @return Timer

    Creates a new Timer Observable, which simulates in realtime while
    subscribed.

    #### Props:

    `duration` is a required prop that specifies the initial time of the timer.

    `isPlaying` specifies that timer should play and stop depending on an
    observable boolean value. If set to `true`, the timer will immediately start
    playing.

    `playOnChange` specifies that the timer should restart whenever an input
    observable changes.
]=]
function Timer.new(props: TimerProps): Timer
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
    local function getCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return math.clamp(
                props.duration - (os.clock() - current.startClockTime),
                0,
                props.duration
            )
        end
        return math.clamp(props.duration - current.resumeAtTime, 0,
            props.duration)
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
    self._duration = props.duration
    self._playState = playState
    setmetatable(self, Timer)
    return self
end

return Timer