--!strict
local Types = require(script.Parent.Parent.Types)
local State = require(script.Parent.Parent.Observables.State)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

--[[
    @param Fusion: any - The Fusion library runtime that the observable belongs to.
    @param fusionStateObject: Fusion.StateObject<T> - The Fusion StateObject to map.
    @return observable: Observable<T> - The Dec Observable created
    @return unsubscribe: () -> () - An unsubscribe function to clean up the Fusion observer

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
): (Observable<T>, Unsubscribe)
    local state = State.new(fusionStateObject:get())

    local unsubscribe = Fusion.Observer(fusionStateObject):onChange(function()
        state:Set(fusionStateObject:get())
    end)
    
    return state, unsubscribe
end

return ObserveFusionState