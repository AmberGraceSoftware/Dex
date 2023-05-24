--!strict
local Types = require(script.Parent.Parent.Types)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param rootInstance: Instance - The root instance to render to.
    @param virtualInstance: Dec.VirtualInstance? - The virtual instance to render.
    @param reconciledNode: Dec.ReconciledNode? - The reconciled node to render.
    @return Dec.ReconciledNode - The reconciled node that was rendered.
    
    Entry point for the Dec reconciler at a top level. This function is called
    by Root objects (created via Dec.CreateRoot) when they are Rendered with
    a new VirtualInstance.
]]
local function RenderVirtualInstance(
    rootInstance: Instance,
    virtualInstance: VirtualInstance?,
    reconciledNode: ReconciledNode?
): ReconciledNode?
    error("Not implemented yet")
end

return RenderVirtualInstance