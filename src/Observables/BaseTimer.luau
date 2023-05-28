--!strict
local Types = require(script.Parent.Parent.Types)

export type Alpha = Types.Alpha
export type BaseTimer = Types.BaseTimer
export type Observable<T> = Types.Observable<T>

local BaseTimer = {}

--[[
    @return void

    Starts the timing-based Observable. The observable will update with new
    values every heartbeat in real-time until it is stopped.
]]
function BaseTimer.Start(self: BaseTimer): ()
    local elapsed = self._playState:Current().resumeAtElapsed
    self._playState:Set({
        playing = true,
        startClockTime = os.clock() - elapsed,
        resumeAtElapsed = 0,
    })
end

--[[
    @return void

    Stops the timing-based Observable.
]]
function BaseTimer.Stop(self: BaseTimer): ()
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = 0,
    })
end

--[[
    @return void

    Pauses the timing-based Observable.
]]
function BaseTimer.Pause(self: BaseTimer): ()
    local currentElapsed = os.clock() - self._playState:Current().startClockTime
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = currentElapsed,
    })
end

--[[
    @return void

    Sets the current time position of the timing-based Observable.
]]
function BaseTimer.SetTimePosition(self: BaseTimer, position: number): ()
    local current = self._playState:Current()
    local elapsed = position
    self._playState:Set({
        playing = current.playing,
        startClockTime = os.clock() - elapsed,
        resumeAtElapsed = current.resumeAtElapsed,
    })
end

--[[
    @return Dec.Alpha - The interpolated Alpha Observable.

    Creates a new Alpha Observable that interpolates between 0 and one using
    the given easing style and direction. Useful for creating non-linear
    animations.
]]
function BaseTimer.EaseAlpha(
    self: BaseTimer,
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha
    -- Create Alpha observable for the current Timer/Stopwatch
    local alpha = self:Alpha()
    -- Apply easing
    return alpha:Ease(easingStyle, easingDirection)
end

--[[
    @return Dec.Alpha - The sliced Alpha Observable.

    Creates a new Alpha Observable that starts at startTime
    (maps to 0) and ends at endTime (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]]
function BaseTimer.SliceAlpha(
    self: BaseTimer,
    startTime: number,
    endTime: number
): Alpha
    -- Create Alpha observable for the current Timer/Stopwatch
    local alpha = self:Alpha()
    -- Create the slice
    return alpha:Slice(startTime / self._duration, endTime / self._duration)
end

--[[
    @return Observable<T> - The interpolated Observable.

    Creates an observable that outputs an interpolated value between
    the start value and end value based on the current elapsed (or remaining) time.
]]
function BaseTimer.Lerp<T>(
    self: BaseTimer,
    startValue: T,
    endValue: T
): Observable<T>
    -- Create Alpha observable for the current Timer/Stopwatch
    local alpha = self:Alpha()
    -- Create the lerp observable
    return alpha:Lerp(startValue, endValue)
end

return BaseTimer
