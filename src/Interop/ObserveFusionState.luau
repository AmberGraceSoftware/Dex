--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

--[=[
    @function ObserveFusionState
    @within Dex
    @param Fusion any
    @param fusionStateObject Fusion.StateObject<T>
    @return Observable<T>

    Interoperability function that maps a Fusion StateObject to a Dex
    Observable object. The returned observable is garbage collected once
    dereferenced and unsubscribed/unmounted.

    The Fusion library must be provided, as Fusion StateObjects only work when
    embedded in a Fusion runtime.
]=]
local function ObserveFusionState<T>(
    Fusion: {Observer: any},
    fusionStateObject: {get: (self: any) -> T}
): Observable<T>
    return Observable.new(
        function()
            return fusionStateObject:get()
        end,
        function(notifyUpdate)
            return Fusion.Observer(fusionStateObject):onChange(notifyUpdate)
        end
    )
end

return ObserveFusionState