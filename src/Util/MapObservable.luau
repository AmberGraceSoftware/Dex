--!strict
--[[
Implements:

]]

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
	dep4: Observable<D4>, dep5: Observable<D4>,
	map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5) -> Return
) -> Observable<Return>)
& (<Return, D1, D2, D3, D4, D5, D6>(
	dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
	dep4: Observable<D4>, dep5: Observable<D4>, dep6: Observable<D4>,
	map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5,
		dep6: D6) -> Return
) -> Observable<Return>)
local MapObservable: ReturnType = function(...)
	local args = table.pack(...)
	local depCount = args.n - 1
	local map = args[args.n]

	error("Not implemented yet!")
end :: any

return MapObservable