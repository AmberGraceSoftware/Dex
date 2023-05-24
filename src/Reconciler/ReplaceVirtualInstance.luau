--!strict

local Types = require(script.Parent.Parent.Types)
local UnmountVirtualInstance = require(script.Parent.UnmountVirtualInstance)
local MountVirtualInstance = require(script.Parent.MountVirtualInstance)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param oldNode: Dec.ReconciledNode - The old node to replace.
    @param virtualInstance: Dec.VirtualInstance - The Virtual Instance to replace the old node with.
    @return Dec.ReconciledNode? - The new Reconciled Node, if the old node was replaced.

    Replaces a reconciled VirtualInstance with a new VirtualInstance, and
    returns the updated ReconciledNode.
]]
local function ReplaceVirtualInstance(
    oldNode: ReconciledNode,
    virtualInstance: VirtualInstance,
    debugLevel: number
): ReconciledNode
    debugLevel += 1
    
    -- This is a naive implementation. In the future, we may want to support
    -- object pooling natively via Dec's reconciler?
    UnmountVirtualInstance(oldNode, debugLevel)
    return MountVirtualInstance(
        oldNode._rootInstance,
        oldNode._childPath,
        virtualInstance,
        debugLevel
    )
end

return ReplaceVirtualInstance