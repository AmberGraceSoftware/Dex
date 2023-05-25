--!strict
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local State = require(script.Parent.State)

export type BaseTimer = Types.BaseTimer

local BaseTimer = {}
BaseTimer.__index = {}
BaseTimer.__index._dectype = "Observable"
BaseTimer.__index._decobservabletype = "BaseTimer"

--[[
    @return void

    Starts the timing-based Observable. The observable will update with new
    values every heartbeat in realtime until it is stopped.
]]
function BaseTimer.__index.Start(self: BaseTimer): ()
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
function BaseTimer.__index.Stop(self: BaseTimer): ()
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
function BaseTimer.__index.Pause(self: BaseTimer): ()
    local currentElapsed = os.clock() - self._playState:Current().startClockTime
    self._playState:Set({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = currentElapsed,
    })
end

BaseTimer.__index.Current = Observable.__index.Current
BaseTimer.__index.Subscribe = Observable.__index.Subscribe
BaseTimer.__index.Destroy = Observable.__index.Destroy

--[[
    @return Dec.BaseTimer - The new BaseTimer instance.

    Creates a new BaseTimer.
]]
function BaseTimer.new(): BaseTimer
    local playState = State.new({
        playing = false,
        startClockTime = 0,
        resumeAtElapsed = 0,
    })
    local function resolveCurrent(_current: typeof(playState:Current())?)
        local current = _current or playState:Current()
        if current.playing then
            return os.clock() - current.startClockTime
        end
        return current.resumeAtElapsed
    end
    local function beginObserving(update: (number) -> ())
        local heartbeatConn = nil
        local function playStateChanged(current: typeof(playState:Current()))
            if current.playing then
                if not heartbeatConn then
                    heartbeatConn = RunService.Heartbeat:Connect(function()
                        update(os.clock() - current.startClockTime)
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
    local self: BaseTimer = Observable.new(
        beginObserving,
        resolveCurrent
    ) :: any
    self._playState = playState
    setmetatable(self, BaseTimer)
    return self
end

return BaseTimer
