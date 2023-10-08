--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local IsObservable = require(ReplicatedStorage.Packages.Dec.Reflection.IsObservable)
local PolymorphicLerp = require(ReplicatedStorage.Packages.Dec.Util.PolymorphicLerp)
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local State = require(script.Parent.State)

export type Tween<T> = Types.Tween<T>
export type TweenParams<T> = Types.TweenParams<T>

--[=[
    @interface TweenParams<T>
    @within Tween
    @field info TweenInfo,
    @field goal T,
    @field start T?,
    @field completed (() -> ())?,
    @field cancelled (() -> ())?,
]=]

--[=[
    @class Tween
    @tag Observable

    #### Inherits [Observable]

    Writeable observable which holds a value which can be re-assigned via
    [State:Set]

    ## Constructor

    ---

    ### Dec.Tween

    ```ts
    Dec.Tween<T>(
        initialValueOrPlayInput: T | Observable<TweenParams<T>>
    ) -> Tween<T>
    ```

    Creates a new [Tween] observable which simulates transitions between values
    over time.

    If an initial value is passed in, the tween will start at the initial value
    provided must be played by calling the [Tween:Play] method

    If an input observable is passed in, the tween will automatic play based on
    whenever that observable changes, using [TweenParams] specified by the input
    observable's current value.

    Tweens can either be played by calling the `:Play()` method
    ```lua
    local tween = Dec.Tween(0)
    tween:Play({
        goal = 1,
        info = TweenInfo.new(0.1)
    })
    ```

    …or automatically play when an input state holding a params table changes:
    ```lua
    local input = Dec.State(0)
    local tween = Dec.Tween(input:Map(currentInput)
        return {
            goal = input,
            info = TweenInfo.new(0.1)
        }
    end))
    input:Set(1)
    ```

    Both methods of tween dispatching can be useful in different scenarios.

    :::info
    Tweens must currently be ***Subscribed*** or ***Mounted*** to exhibit
    expected behavior. This is a requirement for all realtime-simulated
    observables, which enables safe garbage collection when writing Dec
    components.
    :::
]=]

local Tween = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Tween :: any)[k] = v
end
Tween.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Tween.__index :: any)[k] = v
end
Tween.__index._decobservabletype = "Tween"

function Tween._GetDuration(info: TweenInfo)
    local cycleLength
    if info.Reverses then
        cycleLength = info.DelayTime + info.Time * 2
    else
        cycleLength = info.DelayTime + info.Time
    end
    local totalCycles = info.RepeatCount + 1
    return cycleLength * totalCycles
end

function Tween._Interpolate<T>(
    info: TweenInfo,
    start: T,
    goal: T,
    elapsed: number,
    lerp: (T, T, number) -> T
): T
    local cycleLength
    if info.Reverses then
        cycleLength = info.DelayTime + info.Time * 2
    else
        cycleLength = info.DelayTime + info.Time
    end
    local totalCycles = info.RepeatCount + 1
    local cycleElapsed = elapsed % cycleLength
    local cycleNumber = math.floor(elapsed / cycleLength)

    -- if we're past the total cycles, snap to the final value and return
    if cycleNumber >= totalCycles then
        return goal
    end

    local inReverse = info.Reverses
        and (cycleElapsed >= info.DelayTime + info.Time)

    local alpha
    if cycleElapsed < info.DelayTime and not inReverse then
        alpha = 0
    else
        local timePosition
        if inReverse then
            timePosition = 2 * info.Time - cycleElapsed - info.DelayTime
        else
            timePosition = cycleElapsed - info.DelayTime
        end
        alpha = TweenService:GetValue(
            math.clamp(timePosition, 0, info.Time) / info.Time,
            info.EasingStyle,
            info.EasingDirection
        )
    end

    return lerp(start, goal, alpha)
end

--[=[
    @method Play
    @within Tween
    @param params TweenParams<T>

    Plays
]=]
function Tween.__index.Play(
    self: Tween<any>,
    params: TweenParams<any>
): ()
    local startValue = params.start or self:Current()
    self._lastDispatch:Set({
        params = {
            start = startValue,
            goal = params.goal,
            info = params.info,
        },
        startClockTime = os.clock(),
        duration = Tween._GetDuration(params.info),
        completed = startValue == params.goal,
    })
end

--[=[
    @function Tween
    @within Dec
    @param initialValue T
    @return Tween<T>

    Creates a new [Tween] Observable object with the given initial value.
]=]
function Tween.new<T>(initialValue: T): Tween<T>
    local initParams: TweenParams<T>
    if IsObservable(initialValue) then
        initParams = table.clone((initialValue :: any):Current())
        initParams.start = initParams.start or initParams.goal
    else
        initParams = {
            start = initialValue,
            goal = initialValue,
            info = TweenInfo.new(0)
        }
    end
    local lerp = PolymorphicLerp(typeof(initParams.start :: T))
    local lastDispatch = State.new({
        params = initParams,
        startClockTime = os.clock(),
        duration = Tween._GetDuration(initParams.info),
        completed = initParams.start == initParams.goal,
    })
    local self: Tween<T>
    self = Observable.new(
        function(): T
            local currentDispatch = lastDispatch:Current()
            local tweenParams = currentDispatch.params
            if currentDispatch.completed then
                return tweenParams.goal
            end

            local elapsed = os.clock() - currentDispatch.startClockTime
            local alpha = math.clamp(
                elapsed / currentDispatch.duration,
                0, 1
            )
            if alpha == 1 then
                return tweenParams.goal
            else
                return Tween._Interpolate(
                    tweenParams.info,
                    tweenParams.start :: T,
                    tweenParams.goal,
                    elapsed,
                    lerp
                )
            end
        end,
        function(notifyUpdate)
            local dispatchToCancel: typeof(lastDispatch:Current())? = nil
            local heartbeatConn: RBXScriptConnection? = nil

            local function startSimulating()
                if heartbeatConn then
                    return
                end
                heartbeatConn = RunService.Heartbeat:Connect(function()
                    local currentDispatch = lastDispatch:Current()
                    local elapsed = os.clock() - currentDispatch.startClockTime
                    if elapsed > currentDispatch.duration then
                        local completedDispatch = table.clone(currentDispatch)
                        completedDispatch.completed = true
                        if currentDispatch.params.completed then
                            task.defer(currentDispatch.params.completed)
                        end
                        return
                    end
                    notifyUpdate()
                end)
            end
            local function stopSimulating()
                if not heartbeatConn then
                    return
                end
                heartbeatConn:Disconnect()
                heartbeatConn = nil
            end
            local function onDispatchUpdate()
                local currentDispatch = lastDispatch:Current()
                if dispatchToCancel and dispatchToCancel.params.cancelled then
                    task.defer(dispatchToCancel.params.cancelled)
                end
                dispatchToCancel = currentDispatch
                if currentDispatch.completed then
                    stopSimulating()
                else
                    startSimulating()
                end
                notifyUpdate()
            end
            onDispatchUpdate()
            local unsub = lastDispatch:Subscribe(onDispatchUpdate)

            return function()
                unsub()
                stopSimulating()
            end
        end
    ) :: any
    self._lastDispatch = lastDispatch
    setmetatable(self, Tween)
    return self
end

return Tween
