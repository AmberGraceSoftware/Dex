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
    if self._closeUpdateStream then
        return
    end
    task.spawn(function()
        local function notifyUpdate()
            local newValue = self._getCurrent()
            if self._cachedValue == newValue then
                return
            end
            self._cachedValue = newValue
            callListenersSafe(self._listeners, newValue)
        end
        notifyUpdate()
        self._closeUpdateStream = self._createUpdateStream(notifyUpdate)
    end)
end
local function stopObservingIdempotent(self: Observable<any>)
    if not self._closeUpdateStream then
        return
    end
    self._closeUpdateStream()
    self._closeUpdateStream = nil
end

--[[
    @return T - The current value of the observable.

    Returns the current value of the Observable.
]]
function Observable.__index.Current(self: Observable<any>): any
    if self._closeUpdateStream then
        return self._cachedValue
    else
        return self._getCurrent()
    end
end

--[[
    @param mappingFunction: (value: T) -> any - The function to map the value of the observable.
    @return Observable<any> - An Observable that emits the mapped values.

    Creates a new Observable that emits the values from the original Observable mapped by the provided function.
]]
function Observable.__index.Map(
    self: Observable<any>,
    mappingFunction: (value: any) -> any
): Observable<any>
    -- Lazy-load to prevent circular dependency.
    local MapObservable = (require :: any)(script.Parent.Parent.Util.MapObservable)
    return MapObservable(self, mappingFunction)
end


--[[
    @param callback: (value: T) -> () - The function to call when the observable changes.
    @return () -> () - Function to stop receiving updates.

    Subscribes to changes in the Observable. Returns a function that, when
    called, will unsubscribe the callback from the Observable updates.

    WARNING: Make sure you handle the Unsubscribe function whenever a calling
    Subscribe! Observables do not garbage collect until all external listeners
    are unsubscribed.
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

    local unsubscribed = false
    return function()
        if unsubscribed then
            return
        end
        unsubscribed = true
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
    getCurrent: () -> T,
    createUpdateStream: (notifyChange: () -> ()) -> Unsubscribe
): Observable<T>
    return setmetatable({
        _cachedValue = getCurrent(),
        _getCurrent = getCurrent,
        _closeUpdateStream = nil :: Unsubscribe?,
        _createUpdateStream = createUpdateStream,
        _listeners = {},
    }, Observable)
end

return Observable
