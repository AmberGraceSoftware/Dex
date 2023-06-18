--!strict
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
local Types = require(script.Parent.Parent.Types)
local EmitTracedError = require(script.Parent.EmitTracedError)
local VirtualInstanceCreators = require(script.Parent.Parent.VirtualInstanceCreators)
type VirtualInstance = Types.VirtualInstance
type VirtualInstanceDirective = Types.VirtualInstanceDirective
type ReconciledNode = Types.ReconciledNode
type ChildPath = Types.ChildPath
type ChildMap = Types.ChildMap
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>

local function parsePath(path: ChildPath): {string}
    if typeof(path) == "table" then
        local parsed = table.create(#path)
        for _, pathKey in path do
            if typeof(pathKey) == "string" then
                table.insert(parsed, pathKey)
            else
                table.insert(parsed, tostring(pathKey))
            end
        end
        return parsed
    elseif typeof(path) == "number" then
        return {tostring(path)}
    else
        return {path}
    end
end
local RenderVirtualInstance: any = nil
local function RenderChild(
    parentNode: ReconciledNode,
    childKey: string,
    childVirtualInstance: VirtualInstance?
)
    if not RenderVirtualInstance then
        RenderVirtualInstance = (require :: any)(script.Parent.RenderVirtualInstance)
    end
    local existingChildNode = parentNode._childMap[childKey]
    parentNode._childMap[childKey] = RenderVirtualInstance(
        parentNode._instance :: Instance,
        childKey,
        childVirtualInstance,
        existingChildNode
    )
end
local function RenderChildObservable(
    parentNode: ReconciledNode,
    childKey: string,
    childVirtualInstance: Observable<VirtualInstance?>
)
    table.insert(
        parentNode._unsubscribes,
        childVirtualInstance:Subscribe(function(currentChild)
            RenderChild(parentNode, childKey, currentChild)
        end)
    )
    RenderChild(
        parentNode,
        childKey,
        childVirtualInstance:Current()
    )
end

local function ApplyChildrenDirective(
    node: ReconciledNode,
    directive: VirtualInstanceDirective
)
    local childMap = directive._payload
    if IsObservable(childMap) then
        table.insert(
            node._unsubscribes,
            (childMap :: Observable<any>):Subscribe(function(currentChildMap)
                ApplyChildrenDirective(node, {
                    _type = directive._type,
                    _trace = directive._trace,
                    _payload = currentChildMap,
                })
            end)
        )
        ApplyChildrenDirective(node, {
            _type = directive._type,
            _trace = directive._trace,
            _payload = childMap:Current(),
        })
    else
        for childPath: ChildPath,
        virtualInstance: CanBeObservable<VirtualInstance> in childMap do
            local chainedVirtualInstance: any = virtualInstance
            local finalChildKey: string

            -- De-Sugar/Flaten list of multiple names to a chain of Premade
            -- VirtualInstances with each nested child as a VirtualInstance.
            local nameList = parsePath(childPath)
            for i = #nameList, 1, -1 do
                local name = nameList[i]
                if i == 1 then
                    finalChildKey = name
                else
                    local child = chainedVirtualInstance
                    local parent = VirtualInstanceCreators.Premade()
                    parent:AddChild(name, child)
                    chainedVirtualInstance = parent
                    for _, parentDirective in parent._directives do
                        parentDirective._trace = directive._trace
                    end
                end
            end
            if not finalChildKey then
                EmitTracedError(
                    "Error when mounting Child virtual instances: Child " .. 
                    "name path is empty! At least one name expected.",
                    directive._trace
                )
            end
            if IsObservable(chainedVirtualInstance) then
                RenderChildObservable(
                    node,
                    finalChildKey,
                    chainedVirtualInstance
                )
            else
                RenderChild(
                    node,
                    finalChildKey,
                    chainedVirtualInstance
                )
            end
            RenderChild(node, finalChildKey, chainedVirtualInstance)
        end
    end
end
--[[
    @param node: ReconciledNode - The reconciled node to apply child directives on
    @param vInst: VirtualInstance - The virtual instances to read directives from

    Reconciles all Children directives on a virtual instance during the mounting
    process.
]]
local function ApplyChildDirectives(
    node: ReconciledNode,
    virtualInstance: VirtualInstance
)
    for _, directive in virtualInstance._directives do
        if directive._type == "Children" then
            ApplyChildrenDirective(node, directive)
        end
    end
end

return ApplyChildDirectives