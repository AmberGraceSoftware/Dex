--!strict

local RunService = game:GetService("RunService")
local Observable = require(script.Parent.Parent.Observables.Observable)
local Types = require(script.Parent.Parent.Types)

type Observable<T> = Types.Observable<T>

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

--[[
    Creates an eased Observable object based on a target Observable and an
    easing function. This function returns an Observable that smoothly
    transitions to new values whenever the target Observable changes. The easing
    function determines the rate of change. The returned Observable needs to be
    subscribed by at least one listener or mounted on a VirtualInstance to work
    correctly; otherwise, it will only simulate every time :Current() is called.
    
    @param target The Observable whose changes should trigger transitions
    @param easingFunction The function determining the rate of transition
    @return An Observable that smoothly transitions to new values
]]
local function CreateEasedObject<T>(
    target: Observable<T>,
    easingFunction: EasingFunction<T>
): Observable<T>
    local initialValue = target:Current()
    local initialTime = os.clock()
    local easingFrame: EasingFrame<any> = {
        startTime = initialTime,
        startElapsed = 0,
        startValue = initialValue,
        previousTime = initialTime,
        previousElapsed = 0,
        previousValue = initialValue,
        previousVelocity = nil,
        goalValue = initialValue,
        targetMet = true
    }

    return Observable.new(
        function()
            return getCurrent(easingFrame, target, easingFunction)
        end,
        function(notifyUpdate)
            return createUpdateStream(notifyUpdate, easingFrame, target)
        end
    )
end

return CreateEasedObject