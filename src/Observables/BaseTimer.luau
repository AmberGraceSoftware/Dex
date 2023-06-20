--!strict
local Types = require(script.Parent.Parent.Types)
local Alpha = require(script.Parent.Alpha)

export type Alpha = Types.Alpha
export type BaseTimer = Types.BaseTimer
export type Observable<T> = Types.Observable<T>

local BaseTimer = {}

--[[

    Starts the timing-based Observable. The observable will update with new
    values every heartbeat in real-time until it is stopped.
]]
function BaseTimer.Start(self: BaseTimer): ()
    local elapsed = self._playState:Current().resumeAtTime
    self._playState:Set({
        playing = true,
        startClockTime = os.clock() - elapsed,
        resumeAtTime = 0,
    })
end

--[[
    Stops the timing-based Observable.
]]
function BaseTimer.Stop(self: BaseTimer): ()
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
end

--[[
    Pauses the timing-based Observable.
]]
function BaseTimer.Pause(self: BaseTimer): ()
    local currentTime = self:Current()
    if currentTime ~= currentTime then
        currentTime = 0
    end
    if currentTime < 0 then
        currentTime = 0
    end
    if currentTime > self._duration then
        currentTime = self._duration
    end
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtTime = currentTime,
    })
end

--[[
    Sets the current time position of the timing-based Observable.
]]
function BaseTimer.SetTimePosition(self: BaseTimer, position: number): ()
    local current = self._playState:Current()
    local elapsed = position
    if position ~= position then
        position = 0
    end
    if position < 0 then
        position = 0
    end
    if position > self._duration then
        position = self._duration
    end
    self._playState:Set({
        playing = current.playing,
        startClockTime = os.clock() - elapsed,
        resumeAtTime = current.resumeAtTime,
    })
end

--[[
    @return Dec.Alpha - The interpolated Alpha Observable.

    Creates a new Alpha Observable that interpolates between 0 and one using
    the given easing style and direction. Useful for creating non-linear
    animations.
]]
function BaseTimer.CurvedAlpha(
    self: BaseTimer,
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha

    -- Create Alpha observable for the current Timer/Stopwatch
    local alpha = self:Alpha()
    -- Apply easing
    return alpha:Curve(easingStyle, easingDirection)
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
    return Alpha.new(
        self,
        startTime,
        endTime
    )
end

return BaseTimer
