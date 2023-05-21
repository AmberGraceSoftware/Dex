--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type Spring<T> = Types.Spring<T>

local Spring = {}
Spring.__index = {}
Spring.__index._dectype = "Observable"
Spring.__index._decobservabletype = "Spring"

function Spring.__index.SetAngularFrequency(
    self: Spring<any>,
    frequency: number
): ()
    error("Not implemented yet")
end

function Spring.__index.CurrentAngularFrequency(
    self: Spring<any>
): number
    error("Not implemented yet")
end

function Spring.__index.SetTarget(
    self: Spring<any>,
    target: any
): ()
    error("Not implemented yet")
end

function Spring.__index.CurrentTarget(
    self: Spring<any>
): any
    error("Not implemented yet")
end

function Spring.__index.SetPosition(
    self: Spring<any>,
    position: any
): ()
    error("Not implemented yet")
end

Spring.__index.Current = Observable.__index.Current
Spring.__index.Subscribe = Observable.__index.Subscribe
Spring.__index.Destroy = Observable.__index.Destroy

function Spring.new<T>(initialValue: T, angularFrequency: number): Spring<T>
    return setmetatable({
        _current = initialValue,
        _angularFrequency = angularFrequency,
        _target = initialValue,
        -- _consumers = nil,
        -- _consumersWeak = nil,
        -- _snapToGoalTheshold = nil,
    }, Spring :: any)
end

return Spring
