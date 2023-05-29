--!strict

local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)
type Observable<T> = Types.Observable<T>

type ReturnType = (<Return, D1>(
    dep1: Observable<D1>,
    map: (dep1: D1) -> Return
) -> Observable<Return>)
& (<Return, D1, D2>(
    dep1: Observable<D1>, dep2: Observable<D2>,
    map: (dep1: D1, dep2: D2) -> Return
) -> Observable<Return>)
& (<Return, D1, D2, D3>(
    dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
    map: (dep1: D1, dep2: D2, dep3: D3) -> Return
) -> Observable<Return>)
& (<Return, D1, D2, D3, D4>(
    dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
    dep4: Observable<D4>,
    map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4) -> Return
) -> Observable<Return>)
& (<Return, D1, D2, D3, D4, D5>(
    dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
    dep4: Observable<D4>, dep5: Observable<D5>,
    map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5) -> Return
) -> Observable<Return>)
& (<Return, D1, D2, D3, D4, D5, D6>(
    dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
    dep4: Observable<D4>, dep5: Observable<D5>, dep6: Observable<D6>,
    map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5, dep6: D6) -> Return
) -> Observable<Return>)
--[[
    @param ...: Dec.Observable<...T> - Tuple consisting of one or more Observable dependencies and a mapping function.
    @param map: (...T) -> U - The mapping function that takes the values of the Observables and returns a new value.
    @returns Dec.Observable<U> - The new Observable derived from the input Observables and the mapping function.

    Creates a new Observable derived from one or more existing Observables.
    When the values of the input Observables change, the new Observable will
    automatically update to reflect the new value using the provided mapping
    function.
    
    The first arguments to this function are the Observables to derive from.
    The final argument is the mapping function, which takes the values of the
    Observables and returns a new value.
]]
local MapObservable: ReturnType = function(...: any): Observable<any>
    local args = table.pack(...)
    local depCount = args.n - 1
    local map = args[args.n]

    local function getCurrent()
        local values = table.create(depCount)
        for i = 1, depCount do
            table.insert(values, args[i]:Current())
        end
        return map(table.unpack(values))
    end
    local function createUpdateStream(notifyUpdate: () -> ())
        local unsubscribes = {}
        for i = 1, depCount do
            table.insert(unsubscribes, args[i]:Subscribe(notifyUpdate))
        end
        return function()
            for _, unsubscribe in unsubscribes do
                unsubscribe()
            end
        end
    end

    return Observable.new(getCurrent, createUpdateStream)
end :: any

return MapObservable
