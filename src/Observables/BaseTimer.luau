--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type BaseTimer = Types.BaseTimer

local BaseTimer = {}
BaseTimer.__index = {}
BaseTimer.__index._dectype = "Observable"
BaseTimer.__index._decobservabletype = "BaseTimer"

function BaseTimer.__index.Start(self: BaseTimer): ()
    error("Not implemented yet")
end

function BaseTimer.__index.Stop(self: BaseTimer): ()
    error("Not implemented yet")
end

function BaseTimer.__index.Pause(self: BaseTimer): ()
    error("Not implemented yet")
end

function BaseTimer.__index.Resume(self: BaseTimer): ()
    error("Not implemented yet")
end

BaseTimer.__index.Current = Observable.__index.Current
BaseTimer.__index.Subscribe = Observable.__index.Subscribe
BaseTimer.__index.Destroy = Observable.__index.Destroy

function BaseTimer.new(): BaseTimer
    return setmetatable({
        _stepConnection = nil,
        _resumeAt = nil,
        _current = 0,
        -- _consumers = nil,
        -- _consumersWeak = nil,
    }, BaseTimer :: any)
end

return BaseTimer