--!strict

local Types = require(script.Parent.Types)
local VirtualInstance = require(script.Parent.VirtualInstance)
type VirtualInstance = Types.VirtualInstance
type CanBeObservable<T> = Types.CanBeObservable<T>
type ChildMap = Types.ChildMap

local VirtualInstanceCreators = {}

--[=[
    @function New
    @within Dec
    @param className string
    @param props {[string]: any}?
    @param children {[any]: CanBeObservable<VirtualInstance?>}
    @return VirtualInstance

    Creates a new VirtualInstance that represents a newly-created Roblox
    Instance (via Instance.new(className)).
]=]
function VirtualInstanceCreators.New(
    className: string,
    props: {[string]: any}?,
    children: ChildMap?
): VirtualInstance
    return VirtualInstance.new(
        "New",
        className,
        props,
        children,
        1
    )
end

--[=[
    @function Clone
    @within Dec
    @param template Instance
    @param props {[string]: any}?
    @param children {[any]: CanBeObservable<VirtualInstance?>}
    @return VirtualInstance

    Creates a new VirtualInstance that represents a cloned Roblox Instance
    from a given template instance (via template:Clone()).
]=]
function VirtualInstanceCreators.Clone(
    template: Instance | VirtualInstance,
    props: {[string]: any}?,
    children: ChildMap?
): VirtualInstance
    return VirtualInstance.new(
        "Clone",
        template,
        props,
        children,
        1
    )
end

--[=[
    @function Premade
    @within Dec
    @param className string
    @param props {[string]: any}?
    @param children {[any]: CanBeObservable<VirtualInstance?>}
    @return VirtualInstance

    Creates a new VirtualInstance that represents a pre-existing Roblox Instance
    to be decorated. This will modify the properties of an existing instance
    rather than creating or destroying new instanvces.
    
    The instance modified will either be the one that is passed into
    Dec.Root(), or a child of an existing virtual instance that Dec will
    automatically wait for (specified via
    `virtualInstance:Child(path, Dec.Premade( . . . ))` ).
]=]
function VirtualInstanceCreators.Premade(
    className: string,
    props: {[string]: any}?,
    children: ChildMap?
): VirtualInstance
    return VirtualInstance.new(
        "Premade",
        className,
        props,
        children,
        1
    )
end

return VirtualInstanceCreators
