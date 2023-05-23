--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type State<T> = Types.State<T>

local State = {}
State.__index = {}
State.__index._dectype = "Observable"
State.__index._decobservabletype = "State"

function State.__index.Set(
    self: State<any>,
    value: any
): ()
    error("Not implemented yet")
end

State.__index.Current = Observable.__index.Current
State.__index.Subscribe = Observable.__index.Subscribe
State.__index.Destroy = Observable.__index.Destroy

function State.new<T>(initialValue: T): State<T>
    return setmetatable({
        _current = initialValue,
        -- _consumers = nil,
        -- _consumersWeak = nil,
    }, State :: any)
end

return State
