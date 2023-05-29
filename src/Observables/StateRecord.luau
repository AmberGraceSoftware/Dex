--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type StateRecord<T> = Types.StateRecord<T>

local StateRecord = {}
StateRecord.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (StateRecord.__index :: any)[k] = v
end
StateRecord.__index._decobservabletype = "StateRecord"

--[[
    @param value: any - The value to set.
    @return void

    Sets the StateRecord value.
]]
function StateRecord.__index.Set(
    self: StateRecord<any>,
    key: string,
    value: any
): ()
    self._cachedValue[key] = value
    local listenerList = {}
    if self._notifyUpdate then
        table.insert(listenerList, self._notifyUpdate)
    end
    local listenersAtKey = self._notifyRecord[key]
    if listenersAtKey then
        for listener in listenersAtKey do
            table.insert(listenerList, listener)
        end
    end
    for _, listener in listenerList do
        listener()
    end
end

function StateRecord.__index.Current(
    self: StateRecord<any>,
    ...: any
): any
    if select("#", ...) == 0 then
        return self._cachedValue
    else
        local key = (...)
        return self._cachedValue[key]
    end
end

function StateRecord.__index.Replace(
    self: StateRecord<any>,
    newRecord: any
)
    self._cachedValue = newRecord
    local listenerList = {}
    if self._notifyUpdate then
        table.insert(listenerList, self._notifyUpdate)
    end
    for _, listenersAtKey in self._notifyRecord do
        for listener in listenersAtKey do
            table.insert(listenerList, listener)
        end
    end
    for _, listener in listenerList do
        listener()
    end
end

function StateRecord.__index.Index(
    self: StateRecord<any>,
    key: any
)
    return Observable.new(
        function()
            return self._cachedValue[key]
        end,
        function(notifyUpdate)
            local listenersAtKey = self._notifyRecord[key]
            if not listenersAtKey then
                listenersAtKey = {}
                self._notifyRecord[key] = listenersAtKey
            end
            listenersAtKey[notifyUpdate] = true

            return function()
                listenersAtKey[notifyUpdate] = nil
                if not next(listenersAtKey) then
                    self._notifyRecord[key] = nil
                end
            end
        end
    )
end

--[[
    @param initialValue: T - The initial value of the StateRecord.
    @return Dec.StateRecord<T> - The newly created StateRecord observable.

    Creates a new StateRecord observable with the given initial value.
]]
function StateRecord.new<T>(initialValue: T): StateRecord<T>
    local self: StateRecord<T>
    local initialized = false
    self = Observable.new(
        function()
            if not initialized then
                initialized = true
                return initialValue
            end
            return self._cachedValue
        end,
        function(notifyUpdate)
            self._notifyUpdate = notifyUpdate
            return function()
                self._notifyUpdate = nil
            end
        end
    ) :: any
    self._notifyRecord = {}
    setmetatable(self, StateRecord)
    return self
end

return StateRecord
