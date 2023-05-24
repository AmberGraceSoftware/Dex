--!strict

local Symbols = require(script.Parent.Parent.Symbols)
local Types = require(script.Parent.Parent.Types)
type Set<T> = Types.Set<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to apply
        the property map to. Connections and observable cleanups are stored
        here.
    @param propMap: {[string]: any} - The property map to apply to the
        VirtualInstance.
    Applies a property map to a VirtualInstance, catching any Roblox engine
    errors. If an error occurs, it will be logged to the console traced to
    the line of code where the VirtualInstance was created.

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
    local reconciledConns = reconciledNode._connections :: any
    local deferredKeys: {string} = {}
    for key, value in propMap do
        if KEYS_TO_DEFER[key] then
            table.insert(deferredKeys, key)
            continue
        end

        if typeof(value) == "function" then
            table.insert(
                reconciledConns,
                instance[key]:Connect(value)
            )
        elseif typeof(value) == "table" and value._dectype == "Observable" then
            table.insert(
                reconciledConns,
                value:Subscribe(function(newValue)
                    local valueToApply = if (newValue == Symbols.Nil :: any)
                        then nil else newValue
                    instance[key] = valueToApply
                end)
            )
        elseif value == Symbols.Nil then
            instance[key] = nil
        else
            instance[key] = value
        end
    end

    for _, key in deferredKeys do
        instance[key] = propMap[key]
    end
end

return ApplyPropertyMapThrows