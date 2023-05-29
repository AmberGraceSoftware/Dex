--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

--[[
    @param Fusion: any - The Fusion library runtime that the observable belongs to.
    @param fusionStateObject: Fusion.StateObject<T> - The Fusion StateObject to map.
    @return observable: Dec.Observable<T> - The Dec Observable created

    Interoperability function for mapping Fusion StateObjects to Dec Observables.

    Returns the Observable, and an unsubscribe function. If this Observable
    object is instantiated within a Dec Component, you must ensure that you
    call virtualInstance:OnUnmount(unsubscribe) within the component's return
    VirtualInstance in order to prevent memory leaks.

    The Fusion library must be provided, as Fusion StateObjects only work when
    embedded in a Fusion runtime.
]]
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