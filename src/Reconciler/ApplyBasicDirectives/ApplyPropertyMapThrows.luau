--!strict

local Symbols = require(script.Parent.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Parent.Types)
local ConnectEventThrows = require(script.Parent.ConnectEventThrows)
type Set<T> = Types.Set<T>
local NilSymbol = Symbols.Nil

local function applyNilSymbol(value: any): any
    return if value == NilSymbol then nil else value
end

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param propMAp: {[string]: any} - The property map to apply to the VirtualInstance
    @return void

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
    propMap: {[string]: any}
)
    local instance = reconciledNode._instance :: any
    local reconciledUnsubs = reconciledNode._unsubscribes
    local deferredKeys: {string} = {}
    for key, value in propMap do
        if KEYS_TO_DEFER[key] then
            table.insert(deferredKeys, key)
            continue
        end

        if typeof(value) == "function" then
            ConnectEventThrows(reconciledNode, {
                event = key,
                listener = value
            })
        elseif typeof(value) == "table" and value._dectype == "Observable" then
            table.insert(
                reconciledUnsubs,
                value:Subscribe(function(current)
                    instance[key] = applyNilSymbol(current)
                end)
            )
            instance[key] = applyNilSymbol(value:Current())
        else
            instance[key] = applyNilSymbol(value)
        end
    end

    for _, key in deferredKeys do
        instance[key] = propMap[key]
    end
end

return ApplyPropertyMapThrows