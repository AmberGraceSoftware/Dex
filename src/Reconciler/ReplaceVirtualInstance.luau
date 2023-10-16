--!strict

local Types = require(script.Parent.Parent.Types)
local UnmountVirtualInstance = require(script.Parent.UnmountVirtualInstance)
local MountVirtualInstance = require(script.Parent.MountVirtualInstance)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param oldNode: Dex.ReconciledNode - The old node to replace.
    @param virtualInstance: Dex.VirtualInstance - The Virtual Instance to replace the old node with.
    @return Dex.ReconciledNode? - The new Reconciled Node, if the old node was replaced.

    Replaces a reconciled VirtualInstance with a new VirtualInstance, and
    returns the updated ReconciledNode.
]]
local function ReplaceVirtualInstance(
    oldNode: ReconciledNode,
    virtualInstance: VirtualInstance
): ReconciledNode
    -- This is a naive implementation. In the future, we may want to support
    -- object pooling natively via Dex's reconciler?
    UnmountVirtualInstance(oldNode)
    return MountVirtualInstance(
        oldNode._rootInstance,
        oldNode._childPath,
        virtualInstance
    )
end

return ReplaceVirtualInstance