--!strict
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local EasedObject = require(script.Parent.EasedObject)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type EasingFrame<T> = EasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>
type Eased<T> = Types.EasedValue<T>

local function easingFunction<T>(
    info: TweenInfo,
    lerp: (T, T, number) -> T,
    easingFrame: EasingFrame<any>
)
    local cycleLength
    if info.Reverses then
        cycleLength = info.DelayTime + info.Time * 2
    else
        cycleLength = info.DelayTime + info.Time
    end
    local totalCycles = info.RepeatCount + 1
    local cycleElapsed = easingFrame.startElapsed % cycleLength
    local cycleNumber = math.floor(easingFrame.startElapsed / cycleLength)

    -- if we're past the total cycles, snap to the final value and return
    if cycleNumber >= totalCycles then
        return easingFrame.goalValue, 0
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

    return lerp(easingFrame.startValue, easingFrame.goalValue, alpha), 0
end

--[=[
    @class Eased
    @tag Observable

    #### Inherits [Observable]

    Observable object which tweens towards another observable's current value
    every time that value changes.

    Useful for tween animations where the input state changes infrequently, such
    as menu transitions.

    ## Constructor

    ---

    ### Dec.Eased
    ```ts
    Dec.Eased<T>(
        target: Observable<T>
        info: TweenInfo
    ) -> Observable<T>
    ```

    Creates an Observable that eases in realtime every time the input Observable
    changes its value, based on the TweenInfo provided.
    
    :::caution
    Eased must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::
]=]
local Eased = {}
-- Inherits EasedObject metamethods
for k, v in EasedObject :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Eased :: any)[k] = v
end
Eased.__index = {}
-- Inherits EasedObject
for k, v in EasedObject.__index :: any do
    (Eased.__index :: any)[k] = v
end
Eased.__index._decobservabletype = "Eased"

--[=[
    @function Eased
    @within Dec
    @param target Observable<T>
    @param info TweenInfo
    @return Observable<T>
    Creates an Observable that eases in realtime every time the input Observable
    changes its value, based on the TweenInfo provided.
    
    :::caution
    Eased must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::

]=]
function Eased.new<T>(input: Observable<T>, info: TweenInfo): Eased<T>
    local lerp = PolymorphicLerp(typeof(input:Current()))
    local self: Eased<T> = EasedObject.new(
        input,
        function(easingFrame)
            return easingFunction(info, lerp, easingFrame)
        end
    ) :: any
    self._info = info
    setmetatable(self, Eased)
    return self
end

return Eased
