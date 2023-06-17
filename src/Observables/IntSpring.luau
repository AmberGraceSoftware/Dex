--!strict

local EasedObject = require(script.Parent.EasedObject)
local Spring = require(script.Parent.Spring)
local Types = require(script.Parent.Parent.Types)

local ROUND_UP_THRESHOLD = 0.9

type Observable<T> = Types.Observable<T>
type IntSpring<T> = Types.IntSpring<T>

local IntSpring = {}
IntSpring.__index = {}
-- Inherits EasedObject
for k, v in IntSpring.__index :: any do
    (IntSpring.__index :: any)[k] = v
end
IntSpring.__index._decobservabletype = "IntSpring"

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