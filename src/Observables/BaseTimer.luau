--!strict
local Types = require(script.Parent.Parent.Types)

export type BaseTimer = Types.BaseTimer
export type Observable<T> = Types.Observable<T>

local BaseTimer = {}

--[=[
    @method Play
    @within Stopwatch
    Starts the Stopwatch Observable. The observable will update with new
    values every heartbeat in real-time until it is stopped.
]=]
--[=[
    @method Play
    @within Timer
    Starts the Timer Observable. The observable will update with new
    values every heartbeat in real-time until it is stopped.
]=]
function BaseTimer.Play(self: BaseTimer): ()
    local elapsed = self._playState:Current().resumeAtTime
    self._playState:Set({
        playing = true,
        startClockTime = os.clock() - elapsed,
        resumeAtTime = 0,
    })
end

--[=[
    @method Stop
    @within Stopwatch
    Stops the Stopwatch Observable, reseting the elapsed time.
]=]
--[=[
    @method Stop
    @within Timer
    Stops the Timer Observable, reseting the remaining time.
]=]
function BaseTimer.Stop(self: BaseTimer): ()
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtTime = 0,
    })
end

--[=[
    @method Pause
    @within Stopwatch
    Pauses the Stopwatch Observable at its current elapsed time position.
]=]
--[=[
    @method Pause
    @within Timer
    Pauses the Timer Observable at its current remaining time position.
]=]
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

--[=[
    @method Pause
    @within Stopwatch
    Sets the current elapsed time of the Stopwatch.
]=]
--[=[
    @method Pause
    @within Timer
    Sets the current remaining time of the Timer.
]=]
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

return BaseTimer
