--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

type StateRecord<T> = Types.StateRecord<T>
type StateDict<K, V> = Types.StateDict<K, V>
type State<T> = Types.State<T>
type Unsubscribe = Types.Unsubscribe


--[=[
    @class Record
    @tag Observable

    #### Inherits [Observable]

    Writeable observable which holds a record table with predefined keys and
    values.

    Contains utility functions for observing and updating specific keys within
    this table, as well as cheaply oobserving specific keys within this table.

    ## Constructor

    ---

    ### Dec.Record
    ```ts
    Dec.Record<T>(
        initialValue T
    ) -> Record<T>
    ```

    Creates a new [Record] observable with the given initial value.
]=]

--[=[
    @class Dict
    @tag Observable

    #### Inherits [Observable]

    Writeable observable which refers to a dictionary of known key and value
    types.

    Contains utility functions for observing and updating specific keys within
    this table, as well as cheaply observing specific keys within this table.

    ## Constructor

    ---

    ### Dec.Dict
    ```ts
    Dec.Dict<K, V>(
        initialValue {[K]: V}
    ) -> Dict<K, V>
    ```

    Creates a new [Dict] observable with the given initial value.
]=]
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

--[=[
    @method Set
    @within Record
    @param key string
    @param value any

    Sets the value at a specific key.
]=]
--[=[
    @method Set
    @within Dict
    @param key K
    @param value V

    Sets the value at a specific key.
]=]
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

--[=[
    @method Current
    @within Record
    @param key any?
    @return any | T

    Gets the current value at a specific key, or the current value of the whole
    record if no first argument is provided.

    :::caution
    Currently, the value returned by `StateRecord:Current()` with no first
    parameter is mutable! Modifying this value directly may cause unexpected
    behavior!
    :::
]=]
--[=[
    @method Current
    @within Dict
    @param key K?
    @return V | {[K: V]}

    Gets the current value at a specific key, or the current value of the whole
    dictionary if no first argument is provided.

    :::caution
    Currently, the value returned by `StateRecord:Current()` with no first
    parameter is mutable! Modifying this value directly may cause unexpected
    behavior!
    :::
]=]
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

--[=[
    @method Replace
    @within Record
    @param newRecord T

    Replaces entire record with a new value
]=]
--[=[
    @method Replace
    @within Dict
    @param newDict {[K]: V}

    Replaces the entire dictionary with a new value
]=]
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

--[=[
    @method Index
    @within Record
    @param key any
    @return State<any>

    Creates a new observable which observes only a specific key within the
    record. Changes in other keys will not affect subscribers to this indexed
    state.

    The returned observable is also a State object, and setting values in this
    state will set values in the original Record object.

    Example:
    ```lua
    local record = Dec.Record({
        coins = 0,
        items = {},
    })

    local coins = record:Index("coins") :: Dec.State<number>
    local items = record:Index("items") :: Dec.State<number>

    -- . . . Updates in stateRecord will be reflected in coins/items:
    record:Replace({
        coins = 100,
        items = {"Sword"},
    })
    print(coins:Current()) -- 100
    print(items:Current()[1]) -- "Sword"

    -- . . . And vice versa!
    coins:Set(42)
    print(record:Current().coins) -- 42
    ```
]=]
--[=[
    @method Index
    @within Dict
    @param key K
    @return State<V>

    Creates a new observable which observes only a specific key within the
    dictionary. Changes in other keys will not affect subscribers to this
    indexed state.

    The returned observable is also a State object, and setting values in this
    state will set values in the original Dict object.

    Example:
    ```lua
    local playerCoinsDict = Dec.Dict({} :: {[Player]: number})
    
    -- Use Index to observe states at a particular key. 
    local player = game.Players.LocalPlayer
    local ourCoins = playerCoinsDict:Index(player)

    -- . . . Updates in dict will be reflected in ourCoins:
    playerCoinsDict:Replace({ [player] = 100 })
    print(coins:Current()) -- 100

    -- . . . And vice versa!
    coins:Set(42)
    print(playerCoinsDict:Current()[player]) -- 42
    ```
]=]
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
    @function Record
    @within Dec
    @param initialValue T
    @return Record<T>

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

--[=[
    @function Dict
    @within Dec
    @param initialValue: {[K]: V}
    @return Dict<K, V>

    Creates a new Dict state observable with the given initial value.
]=]
StateRecord.newDict = (StateRecord.new :: any)
    :: <K, V>(initialValue: {[K]: V}) -> StateDict<K, V>

return StateRecord
