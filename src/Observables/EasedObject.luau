--!strict

local RunService = game:GetService("RunService")
local Observable = require(script.Parent.Parent.Observables.Observable)
local Types = require(script.Parent.Parent.Types)

type Observable<T> = Types.Observable<T>
type EasedObject<T> = Types.EasedObject<T>

export type EasingFrame<T> = {
    startTime: number,
    startElapsed: number,
    startValue: T,
    previousValue: any,
    previousTime: number,
    previousElapsed: number,
    previousVelocity: any?,
    goalValue: T,
    targetMet: boolean,
}

export type EasingFunction<T> = (easingFrame: EasingFrame<T>) -> (T, any)

local function getCurrent<T>(
    easingFrame: EasingFrame<T>,
    target: Observable<T>,
    easingFunction: EasingFunction<T>
): T
    local currentTime = os.clock()
    local goalValue = target:Current()

    if goalValue ~= easingFrame.goalValue then
        easingFrame.startValue = easingFrame.previousValue
        easingFrame.startTime = easingFrame.previousTime
        easingFrame.goalValue = goalValue
        easingFrame.targetMet = false
    end

    if not easingFrame.targetMet then
        easingFrame.startElapsed = currentTime - easingFrame.startTime
        easingFrame.previousElapsed = currentTime - easingFrame.previousTime
        local currentValue, currentVelocity = easingFunction(easingFrame)
        easingFrame.previousTime = currentTime
        easingFrame.previousValue = currentValue
        easingFrame.previousValue = currentVelocity

        if currentValue == easingFrame.goalValue then
            easingFrame.targetMet = true
            easingFrame.startValue = easingFrame.goalValue
        end

        return currentValue
    end

    return easingFrame.startValue
end

local function createUpdateStream<T>(
    notifyUpdate: () -> (),
    easingFrame: EasingFrame<T>,
    target: Observable<T>
): () -> ()
    local heartbeatConn: RBXScriptConnection? = nil
    local unsubscribe = nil

    local function heartbeatStep()
        local goalValue = target:Current()

        if goalValue ~= easingFrame.goalValue or not easingFrame.targetMet then
            if heartbeatConn and easingFrame.targetMet then
                heartbeatConn:Disconnect()
                heartbeatConn = nil
            end
        end
        notifyUpdate()
    end

    if not easingFrame.targetMet then
        heartbeatConn = RunService.Heartbeat:Connect(heartbeatStep)
    end

    unsubscribe = target:Subscribe(function()
        notifyUpdate()
        if not heartbeatConn then
            heartbeatConn = RunService.Heartbeat:Connect(heartbeatStep)
        end
    end)

    return function()
        if heartbeatConn then
            heartbeatConn:Disconnect()
        end
        if unsubscribe then
            unsubscribe()
        end
    end
end

local typeToInitialVelocity: {[string]: any?} = {
    ["number"] = 0,
    ["Vector2"] = Vector2.zero,
    ["Vector3"] = Vector3.zero,
    ["Vector2Int16"] = Vector2int16.new(0, 0),
    ["Vector3Int16"] = Vector3int16.new(0, 0),
    ["UDim"] = UDim.new(),
    ["UDim2"] = UDim2.new(),
    ["Color3"] = Color3.new(),
    ["Rect"] = Rect.new(0, 0, 0, 0),
    ["CFrame"] = CFrame.identity,
}

local EasedObject = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (EasedObject :: any)[k] = v
end
EasedObject.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (EasedObject.__index :: any)[k] = v
end
EasedObject.__index._decobservabletype = "EasedObject"

function EasedObject.__index.ResetVelocity(self: EasedObject<any>)
    self._easingFrame.previousVelocity =
        typeToInitialVelocity[typeof(self._easingFrame.startValue)]
end
function EasedObject.__index.CurrentTarget(self: EasedObject<any>)
    return self._target:Current()
end
function EasedObject.__index.SetPosition(self: EasedObject<any>, pos: any)
    if typeof(pos) ~= typeof(self._easingFrame.startValue) then
        error(`Invalid argument to SetPosition (` ..
            `{typeof(self._easingFrame.startValue)} expected; got ` ..
            `{typeof(pos)})`)
    end
    local initialTime = os.clock()
    self._easingFrame.previousValue = pos
    self._easingFrame.previousTime = initialTime
    self._easingFrame.previousElapsed = 0
    self._easingFrame.startValue = pos
    self._easingFrame.startTime = initialTime
    self._easingFrame.startElapsed = 0
end

--[[
    Creates an eased Observable object based on a target Observable and an
    easing function. This function returns an Observable that smoothly
    transitions to new values whenever the target Observable changes. The easing
    function determines the rate of change. The returned Observable needs to be
    subscribed by at least one listener or mounted on a VirtualInstance to work
    correctly; otherwise, it will only simulate every time :Current() is called.
    
    @function new
    @within EasedObject
    @private
    @param target The Observable whose changes should trigger transitions
    @param easingFunction The function determining the rate of transition
    @return An Observable that smoothly transitions to new values
]]
function EasedObject.new<T>(
    target: Observable<T>,
    easingFunction: EasingFunction<T>
): EasedObject<T>
    local initialValue = target:Current()
    local initialVelocity = typeToInitialVelocity[typeof(initialValue)]
    if not initialVelocity then
        error("Data type '" .. typeof(initialValue) .. "' can't be eased")
    end
    local initialTime = os.clock()
    local easingFrame: EasingFrame<any> = {
        startTime = initialTime,
        startElapsed = 0,
        startValue = initialValue,
        previousTime = initialTime,
        previousElapsed = 0,
        previousValue = initialValue,
        previousVelocity = initialVelocity,
        goalValue = initialValue,
        targetMet = true
    }

    local self: EasedObject<T> = Observable.new(
        function()
            return getCurrent(easingFrame, target, easingFunction)
        end,
        function(notifyUpdate)
            return createUpdateStream(notifyUpdate, easingFrame, target)
        end
    ) :: any
    self._easingFrame = easingFrame
    self._target = target

    setmetatable(self, EasedObject)

    return self
end

return EasedObject