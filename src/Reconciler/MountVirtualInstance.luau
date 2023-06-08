--!strict

local ApplyBasicDirectives = require(script.Parent.ApplyBasicDirectives)
local ApplyChildDirectives = require(script.Parent.ApplyChildDirectives)
local CreateReconciledNode = require(script.Parent.CreateReconciledNode)
local CreateOrFindReconciledInstance = require(script.Parent.CreateOrFindReconciledInstance)
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
    
    local instancePromise = CreateOrFindReconciledInstance(rootInstance,
        childPath, virtualInstance, debugLevel)
    local node = CreateReconciledNode(
        nil,
        rootInstance,
        childPath
    )
    -- Freeze all VirtualInstances on mount
    if virtualInstance._reconciledNode then
        error("VirtualInstance cannot be mounted more than once", debugLevel)
    end
    virtualInstance._reconciledNode = node
    table.freeze(virtualInstance)
    instancePromise.andThen(function(instance, innerDebugLevel)
        innerDebugLevel += 1
        node._instance = instance
        if (virtualInstance._constructorType == "New")
        or (virtualInstance._constructorType == "Clone") then
            table.insert(node._instancesToCleanup, instance)
        end 
        ApplyBasicDirectives(node, virtualInstance, innerDebugLevel)
        ApplyChildDirectives(node, virtualInstance, innerDebugLevel)
        for callback in node._instanceResolvedCallbacks do
            task.spawn(callback, instance)
        end
    end)
    if not node._instance then
        table.insert(node._unsubscribes, instancePromise.cancel)
    end
    
    return node
end

return MountVirtualInstance