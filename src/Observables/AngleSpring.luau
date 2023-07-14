--!strict
local Types = require(script.Parent.Parent.Types)
local EasedObject = require(script.Parent.EasedObject)

type EasingFrame<T> = EasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>
type AngleSpring<T> = Types.AngleSpring<T>

-- Wraps an angle to the range [-pi, pi]
local function wrapAngle(angle: any): any
    if typeof(angle) == "number" then
        angle %= (math.pi * 2)
        if angle > math.pi then
            angle -= math.pi * 2
        end
        return angle
    end
    if typeof(angle) == "Vector2" then
        return Vector2.new(wrapAngle(angle.X), wrapAngle(angle.Y))
    end
    if typeof(angle) == "Vector3" then
        return Vector3.new(wrapAngle(angle.X), wrapAngle(angle.Y),
            wrapAngle(angle.Z))
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
}

--[=[
    @class AngleSpring
    @tag Observable

    #### Inherits [Observable]

    Observable object which simulates critically damped spring easing towards
    another observable's value, clamping its output to the range `[-pi, pi]`.

    ## Constructor

    ---

    ### Dec.AngleSpring
    ```ts
    Dec.AngleSpring<T>(
        target: Observable<T>
        angularFrequency: number?
    ) -> AngleSpring<T>
    ```
    
    Creates an easing observable that simulates the behavior of a critically
    damped spring, wrapped around the range [-pi, pi]. The spring simulates in
    realtime until the target value is reached.

    :::caution
    AngleSpring must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::
]=]
local AngleSpring = {}
-- Inherits EasedObject metamethods
for k, v in EasedObject :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (AngleSpring :: any)[k] = v
end
AngleSpring.__index = {}
-- Inherits EasedObject
for k, v in EasedObject.__index :: any do
    (AngleSpring.__index :: any)[k] = v
end
AngleSpring.__index._decobservabletype = "AngleSpring"

function AngleSpring.__index.SetPosition(self: AngleSpring<any>, pos: any)
    EasedObject.__index.SetPosition(self, wrapAngle(pos))
end

function AngleSpring.__index.CurrentTarget(self: AngleSpring<any>)
    return wrapAngle(EasedObject.__index.CurrentTarget(self))
end

--[=[
    @function AngleSpring
    @within Dec
    @param target Observable<T>
    @param angularFrequency number?
    @return Observable<T>
    Creates an easing observable that simulates the behavior of a critically
    damped spring, wrapped around the range [-pi, pi]. The spring simulates in
    realtime until the target value is reached.
    
    :::caution
    AngleSpring must have at least one Subscriber (or be mounted on at least one
    VirtualInstance) to simulate in realtime!
    :::
]=]
function AngleSpring.new<T>(
    target: Observable<T>,
    angularFrequency: number?
): AngleSpring<T>
    local targetType = typeof(target:Current())
    local stepMethod = typeToSpringStepMethod[targetType]
    if not stepMethod then
        error(
            "Data type '" .. targetType .. "' cannot be eased using AngleSpring"
        )
    end

    local _angularFrequency = angularFrequency or math.pi * 2
    local self: AngleSpring<T> = EasedObject.new(
        target,
        function(easingFrame)
            return stepMethod(
                _angularFrequency,
                easingFrame
            )
        end
    ) :: any
    self._angularFrequency = _angularFrequency
    setmetatable(self, AngleSpring)
    return self
end

return AngleSpring
