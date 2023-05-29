--!strict
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local CreateEasedObject = require(script.Parent.CreateEasedObject)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type EasingFrame<T> = CreateEasedObject.EasingFrame<T>
type Observable<T> = Types.Observable<T>

local function easingFunction<T>(
    info: TweenInfo,
    lerp: (T, T, number) -> T,
    easingFrame: EasingFrame<any>
)
    local cycleLength
    if info.Reverses then
        cycleLength = info.DelayTime + info.Time * 2
    else
        cycleLength = info.DelayTime + info.Time
    end
    local totalCycles = info.RepeatCount + 1
    local cycleElapsed = easingFrame.startElapsed % cycleLength
    local cycleNumber = math.floor(easingFrame.startElapsed / cycleLength)

    -- if we're past the total cycles, snap to the final value and return
    if cycleNumber >= totalCycles then
        return easingFrame.goalValue, 0
    end

    local inReverse = info.Reverses
        and (cycleElapsed >= info.DelayTime + info.Time)

    local alpha
    if cycleElapsed < info.DelayTime and not inReverse then
        alpha = 0
    else
        local timePosition
        if inReverse then
            timePosition = 2 * info.Time - cycleElapsed - info.DelayTime
        else
            timePosition = cycleElapsed - info.DelayTime
        end
        alpha = TweenService:GetValue(
            math.clamp(timePosition, 0, info.Time) / info.Time,
            info.EasingStyle,
            info.EasingDirection
        )
    end

    return lerp(easingFrame.startValue, easingFrame.goalValue, alpha), 0
end

--[[
    Creates an Observable that eases in realtime every time the input Observable
    changes its value, based on the TweenInfo provided.

    WARNING: The return Observable needs to be subscribed by at least one
    listener or mounted on a VirtualInstance to update in real time; otherwise,
    it will only simulate every time :Current() is called.

    @param target - The target Observable to apply easing to.
    @param info - The TweenInfo object that defines the easing behavior.
    @return An Observable that eases in realtime from changes in the input value

]]
local function Eased<T>(input: Observable<T>, info: TweenInfo): Observable<T>
    local lerp = PolymorphicLerp(typeof(input:Current()))
    return CreateEasedObject(
        input,
        function(easingFrame)
            return easingFunction(info, lerp, easingFrame)
        end
    )
end

return Eased
