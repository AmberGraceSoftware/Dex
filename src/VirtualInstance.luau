--!strict
--[[
    A module for creating and managing Virtual Instances.
    
    Virtual Instances act as a blueprint for actual Roblox Instances.
]]

local Types = require(script.Parent.Types)

export type VirtualInstance = Types.VirtualInstance
export type Observable<T> = Types.Observable<T>
export type CanBeObservable<T> = Types.CanBeObservable<T>
export type TweenState = Types.TweenState
export type State<T> = Types.State<T>

local VirtualInstance = {}
VirtualInstance.__index = {}
VirtualInstance.__index._dectype = "VirtualInstance"

--[[
    @param propertyMap: CanBeObservable<{[string]: any}> - Property map to render
    @return void

    Adds properties to be rendered on the instance when it is reconciled.

    Multiple calls to this function will merge the provided property map with
    the existing one, prioritizing the later call.
]]
function VirtualInstance.__index.Properties(
    self: VirtualInstance,
    propertyMap: CanBeObservable<{[string]: CanBeObservable<any>}>
): ()
    error("Not implemented yet")
end

--[[
    @param TweenState: CanBeObservable<TweenState | {TweenState}> - TweenState or TweenState list to render
    @return void

    Adds Dec.TweenState objects to play on the Virtual Instance. Multiple calls
    to this function will add TweenStates to this list.

    When played, tweens will override properties set using
    virtualInstance.Properties(), and will use Roblox Tween objects under the
    hood.
]]
function VirtualInstance.__index.Tweens(
    self: VirtualInstance,
    TweenState: CanBeObservable<TweenState | {TweenState}>
): ()
    error("Not implemented yet")
end

--[[
    @param attributeMap: CanBeObservable<{[string]: any}> - Attribute map to render
    @return void

    Adds attributes to be rendered on the instance when it is reconciled.
    
    Multiple calls to this function will merge the provided attribute map with
    the existing one, prioritizing the latest calls.
]]
function VirtualInstance.__index.Attributes(
    self: VirtualInstance,
    attributeMap: CanBeObservable<{[string]: CanBeObservable<any>}>
): ()
    error("Not implemented yet")
end

--[[
    @param tags: CanBeObservable<{string}> - CollectionService tags to render.
    @return void

    Adds tags to the Virtual Instance when it is reconciled. Multiple calls to
    this function will add extra tags to the VirtualInstance if they do not
    exist.
]]
function VirtualInstance.__index.Tags(
    self: VirtualInstance,
    tags: CanBeObservable<{string}>
): ()
    error("Not implemented yet")
end

--[[
    @param eventName: string - The name of the event to connect.
    @param signal: (...any) -> () - The function to be called when the event is fired.
    @return void

    Adds an event listener to the Virtual Instance, which will automatically
    be connected and disconnected as the VirtualInstance is reconciled.
]]
function VirtualInstance.__index.Connect(
    self: VirtualInstance,
    eventName: string,
    signal: (...any) -> ()
): ()
    error("Not implemented yet")
end

--[[
    @param propertyName: string - The name of the property to output.
    @param outState: State<any> - The state to output the property to.
    @return void

    Outputs a property from the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutProperty(
    self: VirtualInstance,
    propertyName: string,
    outState: State<any>
): ()
    error("Not implemented yet")
end

--[[
    @param propertyName: string - The name of the attribute to output.
    @param outState: State<any> - The state to output the attribute to.
    @return void

    Outputs an attribute from the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutAttribute(
    self: VirtualInstance,
    propertyName: string,
    outState: State<any>
): ()
    error("Not implemented yet")
end

--[[
    @param outState: State<Instance> | State<Instance?> - The state to output the instance to.
    @return void

    Outputs a reference to the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutInstance(
    self: VirtualInstance,
    outState: State<Instance> | State<Instance?>
): ()
    error("Not implemented yet")
end

--[[
    @return VirtualInstance - A copy of the Virtual Instance.

    Creates a shallow copy of the Virtual Instance.
]]
function VirtualInstance.__index.Copy(
    self: VirtualInstance
): VirtualInstance
    error("Not implemented yet")
end

--[[
    @return VirtualInstance - A deep copy of the VirtualInstance.

    Creates a deep copy of the VirtualInstance and all child VirtualInstances.
]]
function VirtualInstance.__index.DeepCopy(
    self: VirtualInstance
): VirtualInstance
    error("Not implemented yet")
end

--[[
    @param path: CanBeObservable<string | {string}?> - The path of the child to add.
    @param child: CanBeObservable<Instance | VirtualInstance?> - The child VirtualInstance or actual Instance to add.
    @return void

    Adds a child VirtualInstance node to this VirtualInstance.

    The path can be a dot-separated string, or an array of raw string names.

    If the child is an actual Instance, that instance will be reparanted to the
    virtual instance when reconciled, and destroyed when the VirtualInstances is
    unmounted.
    
    If the child is a VirtualInstance, it will be created or found depending on
    the type of VirtualInstance passed in.
]]
function VirtualInstance.__index.Child(
    self: VirtualInstance,
    path: CanBeObservable<string | {string}>,
    child: CanBeObservable<Instance | VirtualInstance | nil>
): ()
    error("Not implemented yet")
end


--[[
    @param childMap: CanBeObservable<{[string | {string} | number]: CanBeObservable<Instance | VirtualInstance?>}>
    @return void

    Adds multiple children to the VirtualInstance given a child map. See
    VirtualInstance:Child() for API reference
]]
function VirtualInstance.__index.Children(
    self: VirtualInstance,
    childMap: CanBeObservable<{
        [string | {string} | number]: CanBeObservable<
            Instance | VirtualInstance | nil
        >
    }>
): ()
    error("Not implemented yet")
end

--[[
    @param callback: (instance: Instance) -> () - The lifecycle callback
    @return void

    Adds a lifecycle callback to be called when the Virtual Instance is mounted.
]]
function VirtualInstance.__index.OnMount(
    self: VirtualInstance,
    callback: (instance: Instance) -> ()
): ()
    error("Not implemented yet")
end

--[[
    @param callback: (instance: Instance) -> () - The lifecycle callback
    @return void

    Adds a lifecycle callback to be called when the Virtual Instance is
    unmounted.
]]
function VirtualInstance.__index.OnUnmount(
    self: VirtualInstance,
    callback: (instance: Instance) -> ()
): ()
    error("Not implemented yet")
end

--[[
    @return VirtualInstance - A new, empty Virtual Instance.

    A mutable element that Dec reconciles into a Roblox Instance.
    When a VirtualInstance is reconciled, its properties are sealed. A
    VirtualInstance should only be mutated by componentt objects before it is
    reconciled. Use Observers instead to mutate a VirtualInstance after it has
    been reconciled.
]]
function VirtualInstance.new(): VirtualInstance
    return setmetatable({
        _current = nil,
        _directives = {},
    }, VirtualInstance)
end

return VirtualInstance
