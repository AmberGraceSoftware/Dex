--!strict

local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
local NilSymbol = Symbols.Nil

local function applyNilSymbol(value: any): any
    return if value == NilSymbol then nil else value
end

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param attributeMap: {[string]: any} - The attribute map to apply to the VirtualInstance
    @return void

    Applies an attribute map to a VirtualInstance, throwing any Roblox engine
    errors. If an error occurs, it should be logged to the console traced to
    the line of code where VirtualInstance:SetAttributes was called.
]]
local function ApplyAttributeMapThrows(
    reconciledNode: Types.ReconciledNode,
    attributeMap: {[string]: any}
)
    local instance = reconciledNode._instance
    local reconciledUnsubs = reconciledNode._unsubscribes
    for key, value in attributeMap do
        if IsObservable(value) then
            table.insert(
                reconciledUnsubs,
                value:Subscribe(function(current)
                    instance:SetAttribute(key, applyNilSymbol(current))
                end)
            )
            instance:SetAttribute(key, applyNilSymbol(value:Current()))
        else
            instance:SetAttribute(key, applyNilSymbol(value))
        end
    end
end

return ApplyAttributeMapThrows