--!strict

local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)
type Observable<T> = Types.Observable<T>

type ReturnType = (<D1>(dep1: Observable<D1>) -> (
    <Return>(map: (D1) -> Return) -> Observable<Return>
)) & (<D1, D2>(dep1: Observable<D1>, dep2: Observable<D2>) -> (
    <Return>(map: (D1, D2) -> Return) -> Observable<Return>
)) & (<D1, D2, D3>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>) -> (
    <Return>(map: (D1, D2, D3) -> Return) -> Observable<Return>
)) & (<D1, D2, D3, D4>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>, dep4: Observable<D4>) -> (
    <Return>(map: (D1, D2, D3, D4) -> Return) -> Observable<Return>
)) & (<D1, D2, D3, D4, D5>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>, dep4: Observable<D4>, dep5: Observable<D5>) -> (
    <Return>(map: (D1, D2, D3, D4, D5) -> Return) -> Observable<Return>
)) & (<D1, D2, D3, D4, D5, D6>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>, dep4: Observable<D4>, dep5: Observable<D5>,
    dep6: Observable<D6>) -> (
    <Return>(map: (D1, D2, D3, D4, D5, D6) -> Return) -> Observable<Return>
)) & (<D1, D2, D3, D4, D5, D6, D7>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>, dep4: Observable<D4>, dep5: Observable<D5>,
    dep6: Observable<D6>, dep7: Observable<D7>) -> (
    <Return>(map: (D1, D2, D3, D4, D5, D6, D7) -> Return) -> Observable<Return>
)) & (<D1, D2, D3, D4, D5, D6, D7, D8>(dep1: Observable<D1>, dep2: Observable<D2>,
    dep3: Observable<D3>, dep4: Observable<D4>, dep5: Observable<D5>,
    dep6: Observable<D6>, dep7: Observable<D7>, dep8: Observable<D8>) -> (
    <Return>(map: (D1, D2, D3, D4, D5, D6, D7, D8) -> Return)
    -> Observable<Return>
))

--[[
    @param ...: Dec.Observable<...T> - Tuple consisting of one or more Observable dependencies
    @returns mapper: ((map: ...Dec.Observable<...T>) -> ReturnType) -> Dec.Observable<ReturnType> - A curryable function which should be called with a mapping function

    Returns a curryable mapping function, which in turn returns a derived
    observable from the dependent observables passed in.
    
    Example usage:

    local x = Dec.State(2)
    local y = Dec.State(3)
    
    local sum = Dec.Map(x, y)(function(currentX, currentY)
        return currentX + currentY
    end)
]]
local MapObservable: ReturnType = function(...: any): any
    local deps = table.pack(...)
    return function(map:(...any) -> any)
        local function getCurrent()
            local values = table.create(#deps)
            for i = 1, deps.n do
                table.insert(values, deps[i]:Current())
            end
            return map(table.unpack(values))
        end
        local function createUpdateStream(notifyUpdate: () -> ())
            local unsubscribes = table.create(#deps)
            for i = 1, deps.n do
                table.insert(unsubscribes, deps[i]:Subscribe(notifyUpdate))
            end
            return function()
                for _, unsubscribe in unsubscribes do
                    unsubscribe()
                end
            end
        end
        return Observable.new(getCurrent, createUpdateStream)
    end
end :: any

return MapObservable
