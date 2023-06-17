--!strict
local EasedObject = require(script.Parent.EasedObject)
local Spring = require(script.Parent.Spring)
local Types = require(script.Parent.Parent.Types)

local ROUND_UP_THRESHOLD = 0.9

local function roundTarget(target: any): any
    if typeof(target) == "number" then
        return math.floor(target + 0.5)
    end
    if typeof(target) == "Vector2" then
        return Vector2.new(roundTarget(target.X), roundTarget(target.Y))
    end
    if typeof(target) == "Vector2int16" then
        return Vector2int16.new(roundTarget(target.X), roundTarget(target.Y))
    end
    if typeof(target) == "Vector3" then
        return Vector3.new(roundTarget(target.X), roundTarget(target.Y),
            roundTarget(target.Z))
    end
    if typeof(target) == "Vector3int16" then
        return Vector3int16.new(roundTarget(target.X), roundTarget(target.Y),
            roundTarget(target.Z))
    end
    if typeof(target) == "UDim" then
        return UDim.new(roundTarget(target.Scale), roundTarget(target.Offset))
    end
    if typeof(target) == "UDim2" then
        return UDim2.new(
            roundTarget(target.X.Scale), roundTarget(target.X.Offset),
            roundTarget(target.Y.Scale), roundTarget(target.Y.Offset)
        )
    end

    return target
end

type Observable<T> = Types.Observable<T>
type IntSpring<T> = Types.IntSpring<T>

local IntSpring = {}
IntSpring.__index = {}
-- Inherits EasedObject
for k, v in EasedObject.__index :: any do
    (IntSpring.__index :: any)[k] = v
end
IntSpring.__index._decobservabletype = "IntSpring"

function IntSpring.__index.CurrentTarget(self: IntSpring<any>)
    return roundTarget(EasedObject.__index.CurrentTarget(self))
end

function IntSpring.__index.SetPosition(self: IntSpring<any>, newPos: any)
    EasedObject.__index.SetPosition(self, roundTarget(newPos))
end

--[[
    Creates an easing observable that simulates the behavior of a critically
    damped spring, constrained to the Integer range. Rounds the current position
    towards the target value, useful for elements like counters. NOTE: Spring
    must have at lease one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate properly! Observables automatically garbage
    collect once the object is dereferenced and all subscribers are disconnected
    (and VirtualInstances unmounted)

    @param target: Observable<T> - The target observable to apply the easing to.
    @param angularFrequency: number? - The angular frequency of the spring
        oscillation. Defaults to Tau (2 * pi) if not provided.
    @return Observable<T> - The resulting easing observable.
]]
function IntSpring.new<T>(
    target: Observable<T>,
    angularFrequency: number?
): IntSpring<T>
    local targetType = typeof(target:Current())
    local stepMethod = Spring.StepMethods[targetType]
    if not stepMethod then
        error(
            "Data type '" .. targetType .. "' cannot be eased using IntSpring"
        )
    end

    local _angularFrequency = angularFrequency or math.pi * 2
    local self: any = EasedObject.new(
        target,
        function(easingFrame)
            local stepDirection = math.sign(
                easingFrame.goalValue - easingFrame.previousValue
            )
            local position, velocity = stepMethod(
                _angularFrequency,
                easingFrame
            )
            if stepDirection == 1 then
                position = math.floor(position + ROUND_UP_THRESHOLD)
            elseif stepDirection == -1 then
                position = math.ceil(position - ROUND_UP_THRESHOLD)
            end
            return position, velocity
        end
    )

    self._angularFrequency = _angularFrequency
    setmetatable(self, IntSpring)

    return self
end

return IntSpring