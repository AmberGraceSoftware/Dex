--!strict

local RunService = game:GetService("RunService")
local Observable = require(script.Parent.Parent.Observables.Observable)
local Types = require(script.Parent.Parent.Types)

type Observable<T> = Types.Observable<T>

export type EasingFunction<T> = (
    startValue: T,
    goalValue: T,
    elapsed: number,
    startVelocity: any
) -> (T, any)

type LastGradient<T> = {
    startTime: number,
    startValue: T,
    lastValue: any,
    goalValue: T,
    startVelocity: any,
    targetMet: boolean
}

local function getCurrent<T>(
    lastGradient: LastGradient<T>,
    target: Observable<T>,
    easingFunction: EasingFunction<T>
): T
    local currentTime = os.clock()
    local goalValue = target:Current()

    if goalValue ~= lastGradient.goalValue then
        lastGradient.startTime = lastGradient.lastValue
        lastGradient.goalValue = goalValue
        lastGradient.startVelocity = 0
        lastGradient.targetMet = false
    end

    if not lastGradient.targetMet then
        local elapsed = currentTime - lastGradient.startTime
        local currentValue, currentVelocity =
            easingFunction(
                lastGradient.startValue,
                lastGradient.goalValue,
                elapsed,
                lastGradient.startVelocity
            )

        if currentValue == lastGradient.goalValue then
            lastGradient.targetMet = true
            lastGradient.startValue = lastGradient.goalValue
        else
            lastGradient.startVelocity = currentVelocity
        end
        lastGradient.lastValue = currentValue

        return currentValue
    end

    return lastGradient.startValue
end

local function createUpdateStream<T>(
    notifyUpdate: () -> (),
    lastGradient: LastGradient<T>,
    target: Observable<T>
): () -> ()
    local heartbeatConn: RBXScriptConnection? = nil
    local unsubscribe = nil

    local function heartbeatStep()
        local goalValue = target:Current()

        if goalValue ~= lastGradient.goalValue or not lastGradient.targetMet then
            if heartbeatConn and lastGradient.targetMet then
                heartbeatConn:Disconnect()
                heartbeatConn = nil
            end
        end
        notifyUpdate()
    end

    if not lastGradient.targetMet then
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
    local lastGradient = {
        startTime = os.clock(),
        startValue = initialValue,
        lastValue = initialValue,
        goalValue = initialValue,
        startVelocity = 0,
        targetMet = true
    }

    return Observable.new(
        function()
            return getCurrent(lastGradient, target, easingFunction)
        end,
        function(notifyUpdate)
            return createUpdateStream(notifyUpdate, lastGradient, target)
        end
    )
end

return CreateEasedObject