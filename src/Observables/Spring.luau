--!strict
local Types = require(script.Parent.Parent.Types)
local EasedObject = require(script.Parent.EasedObject)

type EasingFrame<T> = EasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>
type Spring<T> = Types.Spring<T>

type StepMethod = (
    angularFrequency: number,
    easingFrame: {
        previousElapsed: any,
        previousValue: any,
        previousVelocity: any,
        goalValue: any,
    }
) -> (any, any)
local linearSpringStep: StepMethod = function(angularFrequency, easingFrame)
    local deltaTime = easingFrame.previousElapsed
    local position = easingFrame.previousValue
    local velocity = easingFrame.previousVelocity
    local goalPosition = easingFrame.goalValue
    local offset = position - goalPosition
    local divisorCoefficient = (1 + angularFrequency * deltaTime)
    local nextVelocity =
        (velocity - angularFrequency * angularFrequency * deltaTime * offset)
        / (divisorCoefficient * divisorCoefficient)
    local nextPosition = position + nextVelocity * deltaTime

    -- Snap to target value within certain threshold range
    local epsilon = 0.01 / angularFrequency
    if math.abs(nextPosition - goalPosition) < epsilon then
        return goalPosition
    end

    return nextPosition, nextVelocity
end

local function wrappedLinearSpringStep(
    unwrapPosition: (any) -> {any},
    wrapPosition: ({any}) -> any,
    unwrapVelocity: ((any) -> {any})?,
    wrapVelocity: (({any}) -> any)?
): StepMethod
    local _unwrapVelocity = unwrapVelocity or unwrapPosition
    local _wrapVelocity = wrapVelocity or wrapPosition
    return function(angularFrequency, easingFrame)
        local previousVelocities = _unwrapVelocity(easingFrame.previousVelocity)
        local previousValues = unwrapPosition(easingFrame.previousValue)
        local previousElapsed = easingFrame.previousElapsed
        local goalValues = unwrapPosition(easingFrame.goalValue)

        local outPositions = table.create(#goalValues)
        local outVelocities = table.create(#goalValues)
        for i = 1, #goalValues do
            local pos, vel = linearSpringStep(
                angularFrequency,
                {
                    previousVelocity = previousVelocities[i],
                    previousElapsed = previousElapsed,
                    previousValue = previousValues[i],
                    goalValue = goalValues[i],
                }
            )
            table.insert(outPositions, pos)
            table.insert(outVelocities, vel)
        end
        return wrapPosition(outPositions), _wrapVelocity(outVelocities)
    end
end

local typeToSpringStepMethod = {
    ["number"] = linearSpringStep,
    ["Vector3"] = linearSpringStep,
    ["Vector2"] = linearSpringStep,
    ["Vector2int16"] = linearSpringStep,
    ["Vector3int16"] = linearSpringStep,
    ["UDim"] = wrappedLinearSpringStep(
        function(udimPos: UDim)
            return {
                udimPos.Scale,
                udimPos.Offset
            }
        end,
        function(wrapped: {number})
            return UDim.new(unpack(wrapped))
        end
    ),
    ["UDim2"] = wrappedLinearSpringStep(
        function(udim2Pos: UDim2)
            return {
                udim2Pos.X.Scale,
                udim2Pos.X.Offset,
                udim2Pos.Y.Scale,
                udim2Pos.Y.Offset
            }
        end,
        function(wrapped: {number})
            return UDim2.new(unpack(wrapped))
        end
    ),
    ["Color3"] = wrappedLinearSpringStep(
        function(color3Pos: Color3)
            return {color3Pos:ToHSV()}
        end,
        function(wrapped: {number})
            return Color3.fromHSV(unpack(wrapped))
        end
    ),
    ["Rect"] = wrappedLinearSpringStep(
        function(rectPos: Rect)
            return {rectPos.Min, rectPos.Max}
        end,
        function(wrapped: {Vector2})
            return Rect.new(unpack(wrapped))
        end
    ),
}

--[=[
    @class Spring
    @tag Observable

    #### Inherits [Observable]

    Observable object which simulates critically damped spring easing towards
    another observable's current value

    ## Constructor

    ---

    ### Dec.Spring
    ```ts
    Dec.Spring<T>(
        target: Observable<T>
        angularFrequency: number?
    ) -> Spring<T>
    ```

    Creates an easing observable that simulates the behavior of a critically
    damped spring. The spring simulates in realtime until the target value is
    reached.

    :::caution
    Spring must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::
]=]
local Spring = {}
-- Inherits EasedObject metamethods
for k, v in EasedObject :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Spring :: any)[k] = v
end
Spring.__index = {}
-- Inherits EasedObject
for k, v in EasedObject.__index :: any do
    (Spring.__index :: any)[k] = v
end
Spring.__index._decobservabletype = "Spring"

Spring.StepMethods = typeToSpringStepMethod



--[=[
    @function Spring
    @within Dec
    @param target Observable<T>
    @param angularFrequency number?
    @return Observable<T>
    Creates an easing observable that simulates the behavior of a critically
    damped spring. The spring simulates in realtime until the target value is
    reached.

    :::caution
    Spring must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::

]=]
function Spring.new<T>(
    target: Observable<T>,
    angularFrequency: number?
): Spring<T>
    local targetType = typeof(target:Current())
    local stepMethod = typeToSpringStepMethod[targetType]
    if not stepMethod then
        error(
            "Data type '" .. targetType .. "' cannot be eased using Spring"
        )
    end

    local _angularFrequency = angularFrequency or math.pi * 2
    local self: Spring<T> = EasedObject.new(
        target,
        function(easingFrame)
            return stepMethod(
                _angularFrequency,
                easingFrame
            )
        end
    ) :: any
    self._angularFrequency = _angularFrequency
    setmetatable(self, Spring)
    return self
end

return Spring
