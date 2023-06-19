--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

type StateRecord<T> = Types.StateRecord<T>
type StateDict<K, V> = Types.StateDict<K, V>
type State<T> = Types.State<T>
type Unsubscribe = Types.Unsubscribe

--- @class StateRecord
--- Subclass of Observable
--- Can be constructed via [Dec.StateRecord]
local StateRecord = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (StateRecord :: any)[k] = v
end
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
    if self._valueRef.value[key] == value then
        return
    end
    self._valueRef.value[key] = value
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
        return self._valueRef.value
    else
        local key = (...)
        return self._valueRef.value[key]
    end
end

function StateRecord.__index.Replace(
    self: StateRecord<any>,
    newRecord: any
)
    self._valueRef.value = newRecord
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

local Index = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Index :: any)[k] = v
end
Index.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Index.__index :: any)[k] = v
end
Index.__index._decobservabletype = "State"

function Index.__index.Set(self: any, value: any)
    self._parent:Set(self._key, value)
end

function StateRecord.__index.Index(
    self: StateRecord<any>,
    key: any
): State<any>
    local indexState: any = Observable.new(
        function()
            return self._valueRef.value[key]
        end,
        function(notifyUpdate)
            local listenersAtKey = self._notifyRecord[key]
            if not listenersAtKey then
                listenersAtKey = {}
                self._notifyRecord[key] = listenersAtKey
            end
            listenersAtKey[notifyUpdate] = true
            self._notifyUpdate = notifyUpdate

            return function()
                listenersAtKey[notifyUpdate] = nil
                self._notifyUpdate = nil
                if not next(listenersAtKey) then
                    self._notifyRecord[key] = nil
                end
            end
        end
    )
    indexState._parent = self
    indexState._key = key
    setmetatable(indexState, Index)
    return indexState
end

--[[
    @param initialValue: T - The initial value of the Record state observable.
    @return Dec.Record<T> - The newly created Record state observable.

    Creates a new Record observable with the given initial value.
]]
function StateRecord.new<T>(initialValue: T): StateRecord<T>
    local self: StateRecord<T>
    local initialized = false
    local valueRef = {value = initialValue}
    self = Observable.new(
        function()
            if not initialized then
                initialized = true
                return initialValue
            end
            return valueRef.value
        end,
        function(notifyUpdate)
            self._notifyUpdate = notifyUpdate
            return function()
                self._notifyUpdate = nil
            end
        end
    ) :: any
    -- Flag as allowing redundant updates, since our contained value is mutable.
    ;(self :: any)._ignoreRedundantUpdates = false
    self._notifyRecord = {}
    self._valueRef = valueRef
    setmetatable(self, StateRecord)
    return self
end

--[[
    @param initialValue: {[K]: V} - The initial value of the Dict observable.
    @return Dec.Dict<T> - The newly created Dict observable.

    Creates a new Dict state observable with the given initial value.
]]
StateRecord.newDict = (StateRecord.new :: any)
    :: <K, V>(initialValue: {[K]: V}) -> StateDict<K, V>

return StateRecord
