--!strict
local Types = require(script.Parent.Parent.Types)
local EmitTracedError = require(script.Parent.EmitTracedError)
local ApplyPropertyMapThrows = require(script.Parent.ApplyPropertyMapThrows)
local ApplyAttributeMapThrows = require(script.Parent.ApplyAttributeMapThrows)
local ApplyTagListThrows = require(script.Parent.ApplyTagListThrows)
local ConnectEventThrows = require(script.Parent.ConnectEventThrows)
type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param instance: Instance - The instance to apply virtual instance directives on
    @param vInst: VirtualInstance - The virtual instances to read directives from
    @param node: ReconciledNode - The reconciled node to output unmount tasks to

    Reconciles the basic directives on a virtual instance during the mounting
    process.
]]
local handleDirective: {[string]: (
    node: ReconciledNode,
    payload: any
) -> ()} = {}
handleDirective.Properties = ApplyPropertyMapThrows
handleDirective.Attributes = ApplyAttributeMapThrows
handleDirective.TagList = ApplyTagListThrows
handleDirective.Connect = ConnectEventThrows

local function ApplyBasicDirectives(
    virtualInstance: VirtualInstance,
    node: ReconciledNode,
    debugLevel: number
)
    debugLevel += 1
    for _, directive in virtualInstance._directives do
        local handler = handleDirective[directive._type]
        if not handler then
            error(
                "Reconciler method not implemented yet for directive type '"
                .. directive._type .. "'"
            )
        end
        local success, err = pcall(
            handler :: any, node, directive._payload
        )
        if not success then
            EmitTracedError(
                "Error when mounting VirtualInstance:\n" .. err,
                directive._trace,
                debugLevel
            )
        end
    end
end

return ApplyBasicDirectives