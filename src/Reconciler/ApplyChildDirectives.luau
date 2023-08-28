--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Packages.Dec.Observables.Observable)
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
                    local parent = VirtualInstanceCreators.Premade("Instance")
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
        end
    end
end

local function ApplyMapChildrenDirective(
    node: ReconciledNode,
    directive: VirtualInstanceDirective,
    useObservableValue: boolean
)
    local input: Observable<any> = directive._payload.input
    local map: (any, any) -> VirtualInstance? = directive._payload.map

    local nextUniqueId = 1
    local keyToUniqueId: {[any]: string} = {}
    local keyToLastValue: {[any]: any} = {}
    local keyToObservable: {[any]: {
        observable: Observable<any>,
        notifyUpdate: (() -> ())?,
    }} = {}
    local function handleKeyUpdate(key: any, value: any?, lastValue: any?)
        -- Create/destroy/notify the observable at this key
        if useObservableValue then
            if value == nil then
                keyToObservable[key] = nil
            else
                local observableInfo = keyToObservable[key]
                if observableInfo then
                    if observableInfo.notifyUpdate then
                        observableInfo.notifyUpdate()
                    end
                else
                    local newInfo: {
                        notifyUpdate: (() -> ())?,
                        observable: Observable<any>
                    }
                    newInfo = {
                        observable = Observable.new(
                            function()
                                return keyToLastValue[key]
                            end,
                            function(notifyUpdate)
                                newInfo.notifyUpdate = notifyUpdate
                                return function()
                                    newInfo.notifyUpdate = nil
                                end
                            end
                        )
                    }
                    keyToObservable[key] = newInfo
                end
            end
        end

        local shouldRecreateInstance
        if useObservableValue then
            shouldRecreateInstance = (lastValue == nil) ~= (value == nil)
        else
            shouldRecreateInstance = true
        end
        if not shouldRecreateInstance then
            return
        end

        -- Map the new VirtualInstance to create
        local nextVirtualInstance: VirtualInstance? = nil
        if value ~= nil then
            local mapValueArg
            if useObservableValue then
                mapValueArg = keyToObservable[key].observable
            else
                mapValueArg = value
            end
            
            -- Ignore the result if an error is produced or yielding takes
            -- place.
            task.spawn(function()
                nextVirtualInstance = map(key, mapValueArg)
            end)
        end

        -- Generate a unique string ID for this child based on the key of the
        -- mapped child.
        local childKey
        if keyToUniqueId[key] then
            childKey = keyToUniqueId[key]
        else
            nextUniqueId += 1
            if typeof(key) == "string" then
                childKey = table.concat({
                    "MappedChild_",
                    key,
                    "_",
                    tostring(nextUniqueId)
                })
            elseif typeof(key) == "number" then
                childKey = "MappedChild_" .. tostring(key)
            end
            childKey = "MappedChild_" .. nextUniqueId

            if value ~= nil then
                keyToUniqueId[key] = childKey
            end
        end
        if (value == nil) and keyToUniqueId[key] then
            keyToUniqueId[key] = nil
        end

        RenderChild(
            node,
            childKey,
            nextVirtualInstance
        )
    end

    table.insert(node._unsubscribes, input:Subscribe(function(currentInput)
        local changedKeys = {}
        for k, v in currentInput do
            if v == keyToLastValue[k] then
                continue
            end
            table.insert(changedKeys, k)
        end
        for k in keyToLastValue do
            if currentInput[k] == nil then
                table.insert(changedKeys, k)
            end
        end
        local previousValues = keyToLastValue
        keyToLastValue = table.clone(currentInput)
        for _, key in changedKeys do
            handleKeyUpdate(key, currentInput[key], previousValues[key])
        end
    end, true))
end

local function ApplyDestroyPremadeChildren(
    node: ReconciledNode,
    directive: VirtualInstanceDirective
)
    local instance = node._instance
    if not instance then
        return
    end
    local filter = directive._payload :: string | ((Instance) -> boolean)?

    if filter == nil then
        instance:ClearAllChildren()
    elseif typeof(filter) == "string" then
        for _, object in instance:GetChildren() do
            if object.Name == filter then
                object:Destroy()
            end
        end
    elseif typeof(filter) == "function" then
        for _, object in instance:GetChildren() do
            if filter(object) then
                object:Destroy()
            end
        end
    else
        EmitTracedError(
            "Error when mounting VirtualInstance: Filter argument for" ..
            "VirtualInstance:DestroyPremadeChildren() must be a string or " .. 
            "predicate function!",
            directive._trace
        )
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
        elseif directive._type == "MapChildren" then
            ApplyMapChildrenDirective(node, directive, false)
        elseif directive._type == "MapChildrenByKey" then
            ApplyMapChildrenDirective(node, directive, true)
        elseif directive._type == "DestroyPremadeChildren" then
            ApplyDestroyPremadeChildren(node, directive)
        end
    end
end

return ApplyChildDirectives