--!strict
local Types = require(script.Parent.Parent.Types)
local EasedObject = require(script.Parent.EasedObject)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)
local Tween = require(script.Parent.Tween)

type EasingFrame<T> = EasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>
type Eased<T> = Types.EasedValue<T>

local function easingFunction<T>(
    info: TweenInfo,
    lerp: (T, T, number) -> T,
    easingFrame: EasingFrame<any>
)
    return Tween._Interpolate(
        info,
        easingFrame.startValue,
        easingFrame.goalValue,
        easingFrame.startElapsed,
        lerp
    ), 0
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

    :::info
    Eased must currently be ***Subscribed*** or ***Mounted*** to exhibit
    expected behavior. This is a requirement for all realtime-simulated
    observables, which enables safe garbage collection when writing Dec
    components.
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

    Creates an eased Observable that tweens its value in realtime every time
    the input Observable changes its value, based on the TweenInfo provided.
    
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
