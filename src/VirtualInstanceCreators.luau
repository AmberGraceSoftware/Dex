--!strict

local Types = require(script.Parent.Types)
local VirtualInstance = require(script.Parent.VirtualInstance)
type VirtualInstance = Types.VirtualInstance
type CanBeObservable<T> = Types.CanBeObservable<T>
type ChildMap = Types.ChildMap

local VirtualInstanceCreators = {}

--[[
    @param props: {[string]: any}? - If provided, initializes the VirtualInstance with property assignments
    @param children: Dec.ChildMap? - If provided, initializes the VirtualInstance with children
    @param className: string - The ClassName of the Instance type to create.
    @return Dec.VirtualInstance - The virtual instance that was created.

    Creates a new VirtualInstance that represents a newly-created Roblox
    Instance (via Instance.new(className)).
]]
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

--[[
    @param template: Instance - The Instance to clone.
    @param props: {[string]: any}? - If provided, initializes the VirtualInstance with property assignments
    @param children: Dec.ChildMap? - If provided, initializes the VirtualInstance with children
    @return Dec.VirtualInstance - The virtual instance that was created.

    Creates a new VirtualInstance that represents a cloned Roblox Instance
    from a given template instance (via template:Clone()).
]]
function VirtualInstanceCreators.Clone(
    template: CanBeObservable<Instance | VirtualInstance>,
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

--[[
    @param props: {[string]: any}? - If provided, initializes the VirtualInstance with property assignments
    @param children: Dec.ChildMap? - If provided, initializes the VirtualInstance with children
    @return Dec.VirtualInstance - A new pre-made VirtualInstance.

    Creates a new VirtualInstance that represents a pre-existing Roblox Instance
    to be decorated. This will modify the properties of an existing instance
    rather than creating or destroying new instanvces.
    
    The instance modified will either be the one that is passed into
    Dec.CreateRoot(), or a child of an existing virtual instance that Dec will
    automatically wait for (specified via
    `virtualInstance:Child(path, Dec.Premade( . . . ))` ).
]]
function VirtualInstanceCreators.Premade(
    props: {[string]: any}?,
    children: ChildMap?
): VirtualInstance
    return VirtualInstance.new(
        "Premade",
        nil,
        props,
        children,
        1
    )
end

return VirtualInstanceCreators
