--!strict

local Types = require(script.Parent.Parent.Types)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param rootInstance: Instance - The root Instance to mount the Virtual Instance to.
    @param childPath: string? - The name of the child to mount. If nil, will use root instance or create "DecRoot" under root instance.
    @param virtualInstance: Dec.VirtualInstance - The Virtual Instance to mount.
    @return Dec.ReconciledNode - The Reconciled Node that was mounted.

    Mounts a VirtualInstance to a root instance, and returns the newly created
    ReconciledNode.
]]
local function MountVirtualInstance(
    rootInstance: Instance,
    childPath: string?,
    virtualInstance: VirtualInstance,
    debugLevel: number
): ReconciledNode
    debugLevel += 1
    
    error("Not implemented yet")
end

return MountVirtualInstance