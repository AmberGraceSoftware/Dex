--!strict
local Types = require(script.Parent.Parent.Types)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

local Observable = {}
Observable.__index = {}
Observable.__index._dectype = "Observable"
Observable.__index._decobservabletype = "Observable"

-- Safely calls a set of listeners. Listeners can remove themselves from the set
-- during the call without causing issues.
local function callListenersSafe(listenerSet: {[(any) -> ()]: true}, arg: any)
    local listenerList = {}
    for listener in listenerSet do
        table.insert(listenerList, listener)
    end

    for _, listener in ipairs(listenerList) do
        if listenerSet[listener] then
            task.spawn(listener, arg)
        end
    end
end
local function beginObservingIdempotent(self: Observable<any>)
    if self._destroyed then
        return
    end
    if self._stopObserving then
        return
    end
    task.spawn(function()
        self._stopObserving = self._beginObserving(function(newValue)
            if self._lastValue == newValue then
                return
            end
            self._lastValue = newValue
            callListenersSafe(self._listeners, newValue)
        end)

        local initValue = self._getCurrentUnobserved()
        if self._lastValue ~= initValue then
            self._lastValue = initValue
            callListenersSafe(self._listeners, initValue)
        end
    end)
end
local function stopObservingIdempotent(self: Observable<any>)
    if not self._stopObserving then
        return
    end
    self._stopObserving()
    self._stopObserving = nil
end

--[[
    @return T - The current value of the observable.

    Returns the current value of the Observable.
]]
function Observable.__index.Current(self: Observable<any>): any
    if self._stopObserving then
        return self._lastValue
    else
        return self._getCurrentUnobserved()
    end
end

--[[
    @param callback: (value: T) -> () - The function to call when the observable changes.
    @return () -> () - Function to stop receiving updates.

    Subscribes to changes in the Observable. Returns a function that, when
    called, will unsubscribe the callback from the Observable updates.
]]
function Observable.__index.Subscribe(
    self: Observable<any>,
    callback: (value: any) -> ()
): Unsubscribe
    if self._destroyed then
        error("Cannot subscribe to destroyed Observable")
    end

    beginObservingIdempotent(self)
    self._listeners[callback] = true

    return function()
        self._listeners[callback] = nil
        if not next(self._listeners) then
            stopObservingIdempotent(self)
        end
    end
end

--[[
    @return void

    Destroys the Observable, releasing all its resources and unsubscribing all
    listeners.
]]
function Observable.__index.Destroy(self: Observable<any>)
    if self._destroyed then
        return
    end
    stopObservingIdempotent(self)
    self._listeners = {}
end

--[[
    @param initialValue: T - The initial value of the observable.
    @return Dec.Observable<T> - The new Observable instance.

    Creates a new Dec Observable object with the given initial value.
    Observables are used to hold, derive, or map state within a Dec application.
]]
function Observable.new<T>(
    beginObserving: (update: (value: T) -> ()) -> Unsubscribe,
    getCurrentUnobserved: () -> T
): Observable<T>
    return setmetatable({
        _lastValue = getCurrentUnobserved(),
        _getCurrentUnobserved = getCurrentUnobserved,
        _beginObserving = beginObserving,
        _stopObserving = nil :: Unsubscribe?,
        _listeners = {},
    }, Observable)
end

return Observable
