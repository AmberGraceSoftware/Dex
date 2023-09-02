--!strict
local IsVirtualInstance = require(script.Parent.Parent.Reflection.IsVirtualInstance)
local ChainedSubscribe = require(script.Parent.ChainedSubscribe)
local Observable = require(script.Parent.Parent.Observables.Observable)
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
local Types = require(script.Parent.Parent.Types)
local EmitTracedError = require(script.Parent.EmitTracedError)
local Symbols = require(script.Parent.Parent.Symbols)
local NilSymbol = Symbols.Nil
type VirtualInstance = Types.VirtualInstance
type VirtualInstanceDirective = Types.VirtualInstanceDirective
type ReconciledNode = Types.ReconciledNode
type ChildPath = Types.ChildPath
type ChildMap = Types.ChildMap
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>

local RenderVirtualInstance: any = nil
local function RenderChild(
    parentNode: ReconciledNode,
    childKey: string,
    childVirtualInstance: CanBeObservable<any?>
)
    if not RenderVirtualInstance then
        RenderVirtualInstance = (require :: any)(script.Parent.RenderVirtualInstance)
    end
    local existingCleanup = parentNode._childCleanups[childKey]
    if existingCleanup then
        existingCleanup()
    end
    if IsObservable(childVirtualInstance) then
        parentNode._childCleanups[childKey] = ChainedSubscribe(
            childVirtualInstance :: any,
            function(terminalVInst)
                local existingChildNode = parentNode._childMap[childKey]
                parentNode._childMap[childKey] = RenderVirtualInstance(
                    parentNode._instance :: Instance,
                    childKey,
                    if IsVirtualInstance(terminalVInst)
                        then terminalVInst
                        else nil,
                    existingChildNode
                )
            end,
            true
        )
    else
        parentNode._childCleanups[childKey] = nil
        local existingChildNode = parentNode._childMap[childKey]
        parentNode._childMap[childKey] = RenderVirtualInstance(
            parentNode._instance :: Instance,
            childKey,
            if IsVirtualInstance(childVirtualInstance)
                then childVirtualInstance
                else nil,
            existingChildNode
        )
    end
end

local function ApplyStaticChildMap(
    node: ReconciledNode,
    childMap: {[ChildPath]: CanBeObservable<any>}
)
    for childPath, virtualInstance in childMap do
        local childKey = tostring(childPath)
        RenderChild(
            node,
            childKey,
            virtualInstance
        )
    end
end

local function ApplyChildrenDirective(
    node: ReconciledNode,
    directive: VirtualInstanceDirective
)
    local childMap = directive._payload
    if IsObservable(childMap) then
        local lastKeySet: {[any]: any} = {}
        local function applyDiff(newStaticChildMap: {[any]: any})
            if (typeof(newStaticChildMap) ~= "table")
            or (newStaticChildMap :: any == NilSymbol) then
                newStaticChildMap = {}
            end
            local diff = table.clone(newStaticChildMap)
            local nextKeySet = table.clone(diff)
            for k in lastKeySet do
                if nextKeySet[k] ~= nil then
                    continue
                end
                diff[k] = NilSymbol
            end
            lastKeySet = nextKeySet
            ApplyStaticChildMap(node, diff)
        end
        table.insert(
            node._unsubscribes,
            ChainedSubscribe(childMap, applyDiff, true)
        )
    else
        ApplyStaticChildMap(node, childMap)
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