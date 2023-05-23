--!strict
local Types = require(script.Parent.Parent.Types)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

local Observable = {}
Observable.__index = {}
Observable.__index._dectype = "Observable"
Observable.__index._decobservabletype = "Observable"

--[[
    @return T - The current value of the observable.

    Returns the current value of the Observable.
]]
function Observable.__index.Current(self: Observable<any>): any
    error("Not implemented yet")
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
    error("Not implemented yet")
end

--[[
    @return void

    Destroys the Observable, releasing all its resources and unsubscribing all
    listeners.
]]
function Observable.__index.Destroy(self: Observable<any>)
    error("Not implemented yet")
end

--[[
    @param initialValue: T - The initial value of the observable.
    @return Dec.Observable<T> - The new Observable instance.

    Creates a new Dec Observable object with the given initial value.
    Observables are used to hold, derive, or map state within a Dec application.
]]
function Observable.new<T>(initialValue: T): Observable<T>
    return setmetatable({
        _current = initialValue,
		-- _consumers = nil,
		-- _consumersWeak = nil,
    }, Observable)
end

return Observable
