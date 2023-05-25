--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local BaseTimer = require(script.Parent.BaseTimer)
local Alpha = require(script.Parent.Alpha)
local State = require(script.Parent.State)
local Observable = require(script.Parent.Observable)

export type Timer = Types.Timer
export type Alpha = Types.Alpha

local Timer = {}
Timer.__index = {}
Timer.__index.Start = BaseTimer.__index.Start
Timer.__index.Stop = BaseTimer.__index.Stop
Timer.__index.Pause = BaseTimer.__index.Pause
Timer.__index.Subscribe = BaseTimer.__index.Subscribe
Timer.__index.Destroy = BaseTimer.__index.Destroy
Timer.__index._dectype = BaseTimer.__index._dectype
Timer.__index._decobservabletype = "Timer"

--[[
    @return Dec.Alpha

    Derives an Alpha observable object that maps the duration from 0 (start) to
    1 (finish)
]]
function Timer.__index.Alpha(self: Timer): Alpha
    return Alpha.new(self, 0, self._duration)
end

--[[
    @param duration: number
    @return void

    Sets the duration of the timer.
]]
function Timer.__index.SetDuration(self: Timer, duration: number): ()
    self._duration = duration
end


function Timer.__index.Current(self: Timer): number
    local baseCurrent = BaseTimer.__index.Current(self)
    return math.max(self._duration - baseCurrent, 0)
end


--[[
    @param duration: number
    @return timer: Dec.Timer

    Creates a new Timer observable with the given duration.
]]
function Timer.new(duration: number): Timer
    local self: Timer
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = 0,
    })
    local function resolveCurrent(_current: typeof(playState:Current())?)
        -- Since we are calling the Observable constructor, _duration
        -- initializes to nil first resolution.
        local durationCurrent = self._duration or duration
        local current = _current or playState:Current()
        if current.playing then
            local elapsed = os.clock() - current.startClockTime
            return math.max(0, durationCurrent - elapsed)
        end
        return math.max(0, durationCurrent - current.resumeAtElapsed)
    end
    local function beginObserving(update: (number) -> ())
        local heartbeatConn = nil
        local function playStateChanged(current: typeof(playState:Current()))
            if current.playing then
                if not heartbeatConn then
                    heartbeatConn = RunService.Heartbeat:Connect(function()
                        local elapsed = os.clock() - current.startClockTime
                        if elapsed >= self._duration then
                            playState:Set({
                                playing = false,
                                startClockTime = 0,
                                resumeAtElapsed = 0,
                            })
                        else
                            update(math.max(0, self._duration - elapsed))
                        end
                    end)
                end
            else
                if heartbeatConn then
                    heartbeatConn:Disconnect()
                end
            end
            update(resolveCurrent(current))
        end
        local unsubscribe = playState:Subscribe(playStateChanged)
        playStateChanged(playState:Current())

        return function()
            unsubscribe()
            if heartbeatConn then
                heartbeatConn:Disconnect()
            end
        end
    end
    self = Observable.new(
        beginObserving,
        resolveCurrent
    ) :: any
    self._duration = duration
    self._playState = playState
    setmetatable(self, BaseTimer)
    return self
end

return Timer