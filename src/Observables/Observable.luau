--!strict
local Types = require(script.Parent.Parent.Types)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

local Observable = {}
Observable.__index = {}
Observable.__index._dectype = "Observable"
Observable.__index._decobservabletype = "Observable"

function Observable.__index.Current(self: Observable<any>): any
    error("Not implemented yet")
end

function Observable.__index.Subscribe(
    self: Observable<any>,
    callback: (value: any) -> ()
): Unsubscribe
    error("Not implemented yet")
end

function Observable.__index.Destroy(self: Observable<any>)
    error("Not implemented yet")
end


function Observable.new<T>(initialValue: T): Observable<T>
    return setmetatable({
        _current = initialValue,
		-- _consumers = nil,
		-- _consumersWeak = nil,
    }, Observable)
end

return Observable
