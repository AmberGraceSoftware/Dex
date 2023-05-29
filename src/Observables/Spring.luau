--!strict
local Types = require(script.Parent.Parent.Types)
local CreateEasedObject = require(script.Parent.CreateEasedObject)

type EasingFrame<T> = CreateEasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>

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
    ["Vector2Int16"] = linearSpringStep,
    ["Vector3Int16"] = linearSpringStep,
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

local function Spring<T>(
    target: Observable<T>,
    angularFrequency: number?
): Observable<T>
    local targetType = typeof(target:Current())
    local stepMethod = typeToSpringStepMethod[targetType]
    if not stepMethod then
        error(
            "Invalid type for Spring easing observable: '" .. targetType .. "'"
        )
    end

    local _angularFrequency = angularFrequency or 10
    return CreateEasedObject(
        target,
        function(easingFrame)
            return stepMethod(
                _angularFrequency,
                easingFrame
            )
        end
    )
end

return Spring
