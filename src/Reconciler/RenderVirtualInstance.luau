--!strict
local Types = require(script.Parent.Parent.Types)
local MountVirtualInstance = require(script.Parent.MountVirtualInstance)
local UnmountVirtualInstance = require(script.Parent.UnmountVirtualInstance)
local ReplaceVirtualInstance = require(script.Parent.ReplaceVirtualInstance)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param rootInstance: Instance - The root instance to render to.
    @param virtualInstance: Dec.VirtualInstance? - The virtual instance to render.
    @param reconciledNode: Dec.ReconciledNode? - The previous reconciled node to replace
    @return Dec.ReconciledNode - The reconciled node that was rendered.
    
    Entry point for the Dec reconciler on a VirtualInstance. This function is
    called by Root objects (created via Dec.CreateRoot) when they are Rendered
    with a new VirtualInstance, and also by observable Children updates. Handles
    the logic for mounting, unmounting, and replacing VirtualInstances.
]]
local function RenderVirtualInstance(
    rootInstance: Instance,
    childPath: string?,
    virtualInstance: VirtualInstance?,
    oldReconciledNode: ReconciledNode?
): ReconciledNode?    
    if virtualInstance then
        if oldReconciledNode then
            return ReplaceVirtualInstance(
                oldReconciledNode,
                virtualInstance
            )
        else
            return MountVirtualInstance(
                rootInstance,
                childPath,
                virtualInstance
            )
        end
    else
        if oldReconciledNode then
            return UnmountVirtualInstance(
                oldReconciledNode
            )
        else
            -- Redundant case, nothing to do
            return nil
        end
    end
end

return RenderVirtualInstance