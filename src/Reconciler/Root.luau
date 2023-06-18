--!strict

local Types = require(script.Parent.Parent.Types)
local RenderVirtualInstance = require(script.Parent.RenderVirtualInstance)
local UnmountVirtualInstance = require(script.Parent.UnmountVirtualInstance)

type Root = Types.Root
type VirtualInstance = Types.VirtualInstance
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type ReconciledNode = Types.ReconciledNode

local Root = {}
Root.__index = {}
Root.__index._dectype = "Root"

--[[
    @param node: Dec.VirtualInstance - The Virtual Instance to be reconciled.
    @return Dec.ReconciledNode - The Reconciled Node from the given Virtual Instance.

    Reconciles a Virtual Instance into the root's Roblox Instance. After the
    call, the Virtual Instance is sealed and cannot be mutated. Instead, you
    should use Dec Observers to mutate the Instance after reconciliation.
    
    It returns the Reconciled Node.
]]
function Root.__index.Render(
    self: Root,
    node: VirtualInstance
): ReconciledNode
    self._reconciled = RenderVirtualInstance(
        self._instance,
        nil,
        node,
        self._reconciled
    )
    return self._reconciled :: ReconciledNode
end

--[[
    @return void

    Unmounts the Virtual Instance from the Root, causing it to be removed from
    the DataModel but not destroyed.
]]
function Root.__index.Unmount(self: Root)
    if self._reconciled then
        UnmountVirtualInstance(self._reconciled)
        self._reconciled = nil
    end
end

--[[
    @return void

    Unmounts and destroys the Root and its underlying Roblox Instance. This
    function should be called before discarding a Root object to ensure memory
    is properly freed.
]]
function Root.__index.Destroy(self: Root)
    self:Unmount()
end

--[[
    @param instance: Instance - The underlying Roblox Instance to be managed.
    @return Dec.Root - A new Root instance.

    Creates a new Root instance. The Root is a reference to a real Roblox
    Instance and is used to reconcile Virtual Instances.
]]
function Root.new(instance: Instance): Root
    return setmetatable({
        _instance = instance,
        _reconciled = nil,
    }, Root)
end

return Root
