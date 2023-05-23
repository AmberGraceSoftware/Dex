--!strict
--[[
    A module for creating Virtual Instances.
    
    Provides several convenience methods for creating different types of Virtual Instances.
]]

local Types = require(script.Parent.Types)
local VirtualInstance = require(script.Parent.VirtualInstance)

local VirtualInstanceCreators = {}

--[[
    @param className: string - The ClassName of the Instance type to create.
    @return Types.VirtualInstance - The virtual instance that was created.

    Creates a new VirtualInstance that represents a newly-created Roblox
    Instance (via Instance.new(className)).
]]
function VirtualInstanceCreators.New(className: string): Types.VirtualInstance
    error("Not implemented yet")
end

--[[
    @param template: Instance - The Instance to clone.
    @return Types.VirtualInstance - The virtual instance that was created.

    Creates a new VirtualInstance that represents a cloned Roblox Instance
    from a given template instance (via template:Clone()).
]]
function VirtualInstanceCreators.Clone(
    template: Instance
): Types.VirtualInstance
    error("Not implemented yet")
end

--[[
    @return Types.VirtualInstance - A new pre-made VirtualInstance.

    Creates a new VirtualInstance that represents a pre-existing Roblox Instance
    to be decorated. This will modify the properties of an existing instance
    rather than creating or destroying new instanvces.
    
    The instance modified will either be the one that is passed into
    Dec.CreateRoot(), or a child of an existing virtual instance that Dec will
    automatically wait for (specified via
    `virtualInstance:Child(path, Dec.Premade( . . . ))` ).
]]
function VirtualInstanceCreators.Premade(
    props: {[string]: any}?
): Types.VirtualInstance
    error("Not implemented yet")
end

return VirtualInstanceCreators
