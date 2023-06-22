--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type State<T> = Types.State<T>


--[=[
    @class State
    @tag Observable

    #### Inherits [Observable]

    Writeable observable which holds a value which can be updated via
    [State:Set]

    *(Constructed via [Dec.State])*
]=]
local State = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (State :: any)[k] = v
end
State.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (State.__index :: any)[k] = v
end
State.__index._decobservabletype = "State"

--[=[
    @param value T

    Updates the state's current value.
]=]
function State.__index.Set(
    self: State<any>,
    value: any
): ()
    self._valueRef.value = value
    if self._notifyUpdate then
        self._notifyUpdate()
    end
end

--[=[
    @function State
    @within Dec
    @param initialValue T
    @return State<T>

    Creates a new State Observable object with the given initial value.
]=]
function State.new<T>(initialValue: T): State<T>
    local self: State<T>
    local valueRef = {value = initialValue}
    self = Observable.new(
        function()
            return valueRef.value
        end,
        function(notifyUpdate)
            self._notifyUpdate = notifyUpdate
            return function()
                self._notifyUpdate = nil
            end
        end
    ) :: any
    self._valueRef = valueRef
    setmetatable(self, State)
    return self
end

return State
