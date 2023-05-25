--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type State<T> = Types.State<T>

local State = {}
State.__index = {}
State.__index.Current = Observable.__index.Current
State.__index.Subscribe = Observable.__index.Subscribe
State.__index.Destroy = Observable.__index.Destroy
State.__index._dectype = Observable.__index._dectype
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
    if self._updateAndNotifyListeners then
        self._updateAndNotifyListeners(value)
    else
        self._lastValue = value
    end
end

--[[
    @param initialValue: T - The initial value of the state.
    @return Dec.State<T> - The newly created State observable.

    Creates a new State observable with the given initial value.
]]
function State.new<T>(initialValue: T): State<T>
    local self: State<T>
    local initialized = false
    self = Observable.new(
        function(update: (T) -> ())
            self._updateAndNotifyListeners = update
            return function()
                self._updateAndNotifyListeners = nil
            end
        end,
        function()
            if not initialized then
                initialized = true
                return initialValue
            end
            return self._lastValue
        end
    ) :: any
    setmetatable(self, State)
    return self
end

return State
