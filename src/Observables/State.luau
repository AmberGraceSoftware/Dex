--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type State<T> = Types.State<T>

local State = {}
State.__index = {}
State.__index._dectype = "Observable"
State.__index._decobservabletype = "State"

--[[
    @param value: any - The value to set.
    @return void

    Sets the state value.
]]
function State.__index.Set(
    self: State<any>,
    value: any
): ()
    error("Not implemented yet")
end

State.__index.Current = Observable.__index.Current
State.__index.Subscribe = Observable.__index.Subscribe
State.__index.Destroy = Observable.__index.Destroy

--[[
    @param initialValue: T - The initial value of the state.
    @return Dec.State<T> - The newly created State observable.

    Creates a new State observable with the given initial value.
]]
function State.new<T>(initialValue: T): State<T>
    return setmetatable({
        _current = initialValue,
        _observerCount = 0,
    }, State :: any)
end

return State
