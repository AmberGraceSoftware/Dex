--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type Spring<T> = Types.Spring<T>

local Spring = {}
Spring.__index = {}
Spring.__index._dectype = "Observable"
Spring.__index._decobservabletype = "Spring"

--[[
    @param frequency: number - The angular frequency to set.
    @return void

    Sets the angular frequency of the spring.
]]
function Spring.__index.SetAngularFrequency(
    self: Spring<any>,
    frequency: number
): ()
    error("Not implemented yet")
end

--[[
    @return number - The current angular frequency of the spring.
    
    Returns the current angular frequency of the spring.
]]
function Spring.__index.CurrentAngularFrequency(
    self: Spring<any>
): number
    error("Not implemented yet")
end

--[[
    @param target: any - The target to set for the spring.
    @return void

    Sets the target of the spring.
]]
function Spring.__index.SetTarget(
    self: Spring<any>,
    target: any
): ()
    error("Not implemented yet")
end

--[[
    @return any - The current target of the spring.

    Returns the current target of the spring.
]]
function Spring.__index.CurrentTarget(
    self: Spring<any>
): any
    error("Not implemented yet")
end

--[[
    @param position: any - The position to set for the spring.
    @return void

    Sets the position of the spring.
]]
function Spring.__index.SetPosition(
    self: Spring<any>,
    position: any
): ()
    error("Not implemented yet")
end

Spring.__index.Current = Observable.__index.Current
Spring.__index.Subscribe = Observable.__index.Subscribe
Spring.__index.Destroy = Observable.__index.Destroy

--[[
    @param initialValue: T - The initial value of the spring.
    @param angularFrequency: number - The angular frequency of the spring.
    @return Dec.Spring<T> - The new spring instance.

    Creates a new Spring Observable with the given initial value and angular frequency.
]]
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
