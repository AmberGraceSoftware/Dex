--!strict
local Types = require(script.Parent.Parent.Types)
local CreateEasedObject = require(script.Parent.CreateEasedObject)

type EasingFrame<T> = CreateEasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>

type StepMethod = (
    angularFrequency: number,
    easingFrame: EasingFrame<any>
) -> (any, any)
local linearSpringStep: StepMethod = function(angularFrequency, easingFrame)
    local deltaTime = easingFrame.previousElapsed
    local position = easingFrame.previousValue
    local velocity = easingFrame.previousVelocity
    local offset = position - easingFrame.goalValue
    local divisorCoefficient = (1 + angularFrequency * deltaTime)
    local nextVelocity =
        (velocity - angularFrequency * angularFrequency * deltaTime * offset)
        / (divisorCoefficient * divisorCoefficient)
    local nextPosition = position + nextVelocity * deltaTime

    return nextPosition, nextVelocity
end

local typeToSpringStepMethod = {
    ["number"] = linearSpringStep,
    ["Vector3"] = linearSpringStep,
    ["Vector2"] = linearSpringStep,
    ["Vector2Int16"] = linearSpringStep,
    ["Vector3Int16"] = linearSpringStep,
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
