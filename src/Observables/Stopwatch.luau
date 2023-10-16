--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local BaseTimer = require(script.Parent.BaseTimer)
local State = require(script.Parent.State)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)
local CreateBaseTimerUpdateStream = require(script.Parent.CreateBaseTimerUpdateStream)

type Stopwatch = Types.Stopwatch
type StopwatchProps = Types.StopwatchProps
type Observable<T> = Types.Observable<T>

--[=[
    @class Stopwatch
    @tag Observable

    #### Inherits [Observable]

    Observable which counts up to a max value in realtime whenever played
    via [Stopwatch:Play].

    Includes utility methods for mapping this "elapsed time" value into more
    complex animationed sequences.

    Includes utility methods for mapping this "remaining time" value into more
    complex animationed sequences.

    ## Constructor
    
    ---
    
    ### Dex.Stopwatch
    ```lua
    Dex.Stopwatch({
        duration: number?,
        isPlaying: CanBeObservable<boolean>?,
        playOnChange: Observable<any>?,
    }?) -> Stopwatch
    ```

    Creates a new [Stopwatch] Observable, which simulates in realtime while
    subscribed.

    #### Props:

    `duration` is an optional prop that specifies the end time of the stopwatch.
    Defaults to `math.huge`.

    `isPlaying` specifies that stopwatch should play and stop depending on an
    observable boolean value. If set to `true`, the stopwatch will immediately
    start playing.

    `playOnChange` specifies that the stopwatch should restart whenever an input
    observable changes.

    ----
    Stopwatches can safely be garbage collected while dereferenced, unsubscribed,
    and unused by a VirtualInstance.

    :::info
    Stopwatches must currently be ***Subscribed*** or ***Mounted*** to exhibit
    expected behavior. This is a requirement for all realtime-simulated
    observables, which enables safe garbage collection when writing Dex
    components.
    :::

    Usage Example:
    ```lua
    local stopwatch = Dex.Stopwatch({
        duration = 10,
        isPlaying = true,
    })
    local frame = Dex.New("Frame")({
        -- Opaque for 5 seconds, then fades to Transparent over 5 seconds:
        BackgroundTransparency = stopwatch:Alpha(5, 10),
    })
    ```
]=]
local Stopwatch = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Stopwatch :: any)[k] = v
end
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

--[=[
    @method Lerp
    @within Stopwatch
    @return Observable<T>

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current elapsed time.
]=]
function Stopwatch.__index.Lerp<T>(
    self: Stopwatch,
    startValue: T,
    endValue: T
): Observable<T>
    local interpolator = PolymorphicLerp(typeof(startValue))
    return MapObservable(self)(function(current)
        local alpha = math.clamp(
            current / self._duration,
            0, 1
        )
        return interpolator(startValue, endValue, alpha)
    end) :: any
end

--[=[
    @method Alpha
    @within Stopwatch
    @param startTime number
    @param endTime number
    @return Alpha

    Derives an observable number that maps the elasped time from 0 at the
    provided start time, and 1 at the provided end time.
]=]
function Stopwatch.__index.Alpha(
    self: Stopwatch,
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


--[=[
    @interface StopwatchProps
    @within Stopwatch
    @field duration number
    @field isPlaying CanBeObservable<boolean>?,
    @field playOnChange Observable<any>?,

    Type that specifies the props for constructing a [Stopwatch] observable (via
    [Dex.Stopwatch])

    `duration` is an optional prop that specifies the end time of the stopwatch.
    Defaults to `math.huge`.

    `isPlaying` specifies that stopwatch should play and stop depending on an
    observable boolean value. If set to `true`, the stopwatch will immediately
    start playing.

    `playOnChange` specifies that the stopwatch should restart whenever an input
    observable changes.
]=]

--[=[
    @function Stopwatch
    @within Dex
    @param props StopwatchProps?
    @return Stopwatch

    Creates a new [Stopwatch] Observable, which simulates in realtime while
    subscribed.

    #### Props:

    `duration` is an optional prop that specifies the end time of the stopwatch.
    Defaults to `math.huge`.

    `isPlaying` specifies that stopwatch should play and stop depending on an
    observable boolean value. If set to `true`, the stopwatch will immediately
    start playing.

    `playOnChange` specifies that the stopwatch should restart whenever an input
    observable changes.
]=]
function Stopwatch.new(props: StopwatchProps?): Stopwatch
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
    local duration = (if props then props.duration else nil) or math.huge
    local function getCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return math.clamp(
                os.clock() - current.startClockTime,
                0,
                duration
            )
        end
        return current.resumeAtTime
    end
    local self: Stopwatch = Observable.new(
        getCurrent,
        CreateBaseTimerUpdateStream(playState, props)
    ) :: any
    self._duration = duration
    self._playState = playState
    setmetatable(self, Stopwatch)
    return self
end

return Stopwatch
