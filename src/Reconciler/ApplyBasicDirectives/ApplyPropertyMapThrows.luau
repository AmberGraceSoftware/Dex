--!strict

local ChainedSubscribe = require(script.Parent.Parent.ChainedSubscribe)
local Symbols = require(script.Parent.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Parent.Types)
local ConnectEventThrows = require(script.Parent.ConnectEventThrows)
type Set<T> = Types.Set<T>
local NilSymbol = Symbols.Nil

local function applyNilSymbol(value: any): any
    return if value == NilSymbol then nil else value
end

local function ApplyReferenceToNode(
    instance: any,
    key: string,
    referencedNode: Types.ReconciledNode
): (() -> ())?
    if referencedNode._instance then
        instance[key] = referencedNode._instance
    end
    local resolvedCallbacks = referencedNode._instanceResolvedCallbacks

    local callback = function(refInstance)
        instance[key] = refInstance
    end
    resolvedCallbacks[callback] = true

    return function()
        resolvedCallbacks[callback] = nil
    end
end

local function ApplyReferenceToVInst(
    instance: any,
    key: string,
    referencedVInst: Types.VirtualInstance
): (() -> ())?
    if referencedVInst._reconciledNode then
        return ApplyReferenceToNode(
            instance,
            key,
            referencedVInst._reconciledNode
        )
    end

    local innerCleanup = nil
    local callback = function(node: Types.ReconciledNode)
        innerCleanup = ApplyReferenceToNode(
            instance,
            key,
            node
        )
    end
    referencedVInst._onReconciledNodeCallbacks[callback] = true
    return function()
        referencedVInst._onReconciledNodeCallbacks[callback] = nil
        if innerCleanup then
            innerCleanup()
        end
    end
end

--[[
    @param reconciledNode: Dex.ReconciledNode - The reconciled node to store cleanup tasks on
    @param propMap: {[string]: any} - The property map to apply to the VirtualInstance

    Applies a property map to a VirtualInstance, throwing any Roblox engine
    errors. If an error occurs, it should be logged to the console traced to
    the line of code where VirtualInstance:SetProperties was called.

    Certain properties (such as Parent) will be applied last.
]]
local KEYS_TO_DEFER: Set<string> = {
    Parent = true,
}
local function ApplyPropertyMapThrows(
    reconciledNode: Types.ReconciledNode,
    propMap: {[string]: any},
    listenersByKey: {[string]: {(...any) -> ()}}
)
    local instance = reconciledNode._instance :: any
    local reconciledUnsubs = reconciledNode._unsubscribes
    local deferredKeys: {string} = {}
    for key, value in propMap do
        if KEYS_TO_DEFER[key] then
            table.insert(deferredKeys, key)
            continue
        end

        if typeof(value) == "table" then
            if value._dectype == "Observable" then
                local instanceRefCleanup: (() -> ())? = nil
                table.insert(
                    reconciledUnsubs,
                    ChainedSubscribe(value, function(current: any)
                        if instanceRefCleanup then
                            instanceRefCleanup()
                            instanceRefCleanup = nil
                        end

                        if current == NilSymbol then
                            instance[key] = nil
                        elseif typeof(current) == "table"
                        and current._dectype == "VirtualInstance" then
                            instanceRefCleanup = ApplyReferenceToVInst(
                                instance,
                                key,
                                current
                            )
                        else
                            instance[key] = applyNilSymbol(current)
                        end
                    end)
                )
                table.insert(reconciledUnsubs, function()
                    if instanceRefCleanup then
                        instanceRefCleanup()
                    end
                end)
            elseif value._dectype == "VirtualInstance" then
                local cleanup = ApplyReferenceToVInst(
                    instance,
                    key,
                    value
                )
                if cleanup then
                    table.insert(reconciledUnsubs, cleanup)
                end
            elseif value == NilSymbol then
                instance[key] = nil
            end
        else
            instance[key] = applyNilSymbol(value)
        end
    end

    for _, key in deferredKeys do
        instance[key] = propMap[key]
    end
    for key, listeners in listenersByKey do
        for _, listener in listeners do
            ConnectEventThrows(reconciledNode, {
                event = key,
                listener = listener
            })
        end
    end
end

function ApplyPropertyMapCollated(
    reconciledNode: Types.ReconciledNode,
    directives: {{_payload: {[string]: any}, _trace: any?}}
)
    local unifiedPropertyMap = table.clone(directives[1]._payload)
    for i = 2, #directives do
        for k, v in directives[i]._payload do
            unifiedPropertyMap[k] = v
        end
    end
    local listenersByKey: {[string]: {(...any) -> ()}} = {}
    for _, directive in directives do
        for k, v in directive._payload do
            if typeof(v) == "function" then
                unifiedPropertyMap[k] = nil
                local listeners = listenersByKey[k]
                if not listeners then
                    listeners = {}
                    listenersByKey[k] = listeners
                end
                table.insert(listeners, v :: any)
            end
        end
    end
    ApplyPropertyMapThrows(reconciledNode, unifiedPropertyMap, listenersByKey)
end

return ApplyPropertyMapCollated