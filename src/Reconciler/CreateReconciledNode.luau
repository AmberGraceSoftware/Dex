--!strict
local Types = require(script.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode

--[[
    @param instance: Instance - The instance that was created or found
    @param rootInstance: Instance - The root instance that was used to create the first parameter
    @param childPath: string? - The child path that was used to create the first parameter
    @return ReconciledNode
    Creates a reconciled node from simpler parameters
]]
local function CreateReconciledNode(
    instance: Instance?,
    rootInstance: Instance,
    childPath: string?
): ReconciledNode
    return {
        _dectype = "ReconciledNode",
        _instance = instance,
        _instanceResolvedCallbacks = {},
        _rootInstance = rootInstance,
        _childPath = childPath,
        _instancesToCleanup = {},
        _connections = {},
        _unsubscribes = {},
        _childMap = {},
        _childCleanups = {},
    }
end

return CreateReconciledNode