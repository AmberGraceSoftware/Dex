--!strict

local Symbols = require(script.Parent.Parent.Parent.Symbols)
local ChainedSubscribe = require(script.Parent.Parent.ChainedSubscribe)
local Types = require(script.Parent.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
type ReconciledNode = Types.ReconciledNode
local NilSymbol = Symbols.Nil

local function applyNilSymbol(value: any): any
    return if value == NilSymbol then nil else value
end

--[[
    @param reconciledNode: Dex.ReconciledNode - The reconciled node to store cleanup tasks on
    @param attributeMap: {[string]: any} - The attribute map to apply to the VirtualInstance
    
    Applies an attribute map to a VirtualInstance, throwing any Roblox engine
    errors. If an error occurs, it should be logged to the console traced to
    the line of code where VirtualInstance:SetAttributes was called.
]]
local function ApplyAttributeMapThrows(
    reconciledNode: ReconciledNode,
    attributeMap: {[string]: any}
)
    local instance = reconciledNode._instance :: Instance
    local reconciledUnsubs = reconciledNode._unsubscribes
    for key, value in attributeMap do
        if IsObservable(value) then
            table.insert(
                reconciledUnsubs,
                ChainedSubscribe(value, function(current)
                    instance:SetAttribute(key, applyNilSymbol(current))
                end)
            )
        else
            instance:SetAttribute(key, applyNilSymbol(value))
        end
    end
end

local function ApplyAttributeMapCollated(
    reconciledNode: ReconciledNode,
    directives: {_payload: {[string]: any}, _trace: any?}
)
    if #directives == 1 then
        ApplyAttributeMapThrows(reconciledNode, directives[1]._payload)
    end
    local unifiedPropertyMap = table.clone(directives[1]._payload)
    for i = 2, #directives do
        for k, v in directives[i]._payload do
            unifiedPropertyMap[k] = v
        end
    end
    ApplyAttributeMapThrows(reconciledNode, unifiedPropertyMap)
end
return ApplyAttributeMapCollated