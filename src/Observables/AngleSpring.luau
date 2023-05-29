--!strict
local Types = require(script.Parent.Parent.Types)
local CreateEasedObject = require(script.Parent.CreateEasedObject)

type EasingFrame<T> = CreateEasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>

-- Wraps an angle to the range [-pi, pi]
local function wrapAngle(angle: number): number
    angle %= (math.pi * 2)
    if angle > math.pi then
        angle -= math.pi * 2
    end
    return angle
end

local linearSpringStep = function(
    angularFrequency: number,
    easingFrame: EasingFrame<number>
)
    local deltaTime = easingFrame.previousElapsed
    local goalPosition = wrapAngle(easingFrame.goalValue)
    local position = easingFrame.previousValue % (math.pi * 2)
    if position - goalPosition > math.pi then
        position -= math.pi * 2
    end
    local velocity = easingFrame.previousVelocity
    local offset = position - goalPosition
    local divisorCoefficient = (1 + angularFrequency * deltaTime)
    local nextVelocity =
        (velocity - angularFrequency * angularFrequency * deltaTime * offset)
        / (divisorCoefficient * divisorCoefficient)
    local nextPosition = wrapAngle(position + nextVelocity * deltaTime)

    -- Snap to target value within certain threshold range
    local epsilon = 0.01 / angularFrequency
    if math.abs(nextPosition - goalPosition) < epsilon then
        return goalPosition
    end

    return nextPosition, nextVelocity
end

local typeToSpringStepMethod = {
    ["number"] = linearSpringStep,
    ["Vector3"] = linearSpringStep,
    ["Vector2"] = linearSpringStep,
    ["Vector2int16"] = linearSpringStep,
    ["Vector3int16"] = linearSpringStep,
}

local function AngleSpring<T>(
    target: Observable<T>,
    angularFrequency: number?
): Observable<T>
    local targetType = typeof(target:Current())
    local stepMethod = typeToSpringStepMethod[targetType]
    if not stepMethod then
        error(
            "Data type '" .. targetType .. "' cannot be eased using AngleSpring"
        )
    end

    local _angularFrequency = angularFrequency or math.pi * 2
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

return AngleSpring
