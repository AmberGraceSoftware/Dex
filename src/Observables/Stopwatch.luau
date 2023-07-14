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

--[=[
    @class Stopwatch
    @tag Observable

    #### Inherits [Observable]

    Observable which counts up to a max value in realtime whenever played
    via [Timer:Start].

    Includes utility methods for mapping this "elapsed time" value into more
    complex animationed sequences.

    ## Constructor
    
    ---
    
    ### Dec.Stopwatch
    ```lua
    Dec.Stopwatch(maxDuration number?) -> Stopwatch
    ```

    Creates a new [Stopwatch] Observable, the value of which increases in realtime
    after [Stopwatch:Start] is called.

    Stopwatches can safely be garbage collected while dereferenced, unsubscribed,
    and unused by a VirtualInstance.
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
    @method Alpha
    @within Stopwatch
    @return Alpha

    Derives an Alpha observable object that maps the elasped time from 0 (start)
    to 1 (finish)
]=]
function Stopwatch.__index.Alpha(self: Stopwatch): Alpha
    return Alpha.new(self, 0, self._duration)
end

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
    @function Stopwatch
    @within Dec
    @param maxDuration number?
    @return Stopwatch

    Creates a new Stopwatch Observable, which simulates in realtime while
    subscribed.
]=]
function Stopwatch.new(maxDuration: number?): Stopwatch
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
    local function getCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return math.clamp(
                os.clock() - current.startClockTime,
                0,
                maxDuration or math.huge
            )
        end
        return current.resumeAtTime
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
    self._duration = maxDuration or math.huge
    self._playState = playState
    setmetatable(self, Stopwatch)
    return self
end

return Stopwatch
