--!strict
local Types = require(script.Parent.Parent.Types)
local EmitTracedError = require(script.Parent.EmitTracedError)
local ApplyPropertyMapThrows = require(script.ApplyPropertyMapThrows)
local ApplyAttributeMapThrows = require(script.ApplyAttributeMapThrows)
local ApplyTagListsThrows = require(script.ApplyTagListsThrows)
local ConnectEventThrows = require(script.ConnectEventThrows)
local OutputPropertyThrows = require(script.OutputPropertyThrows)
local OutputAttributeThrows = require(script.OutputAttributeThrows)
local OutputInstanceRefThrows = require(script.OutputInstanceRefThrows)
local HandleOnMountCallbackThrows = require(script.HandleOnMountCallbackThrows)
local HandleOnUnmountCallbackThrows = require(script.HandleOnUnmountCallbackThrows)
type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

--[[
    @param instance: Instance - The instance to apply virtual instance directives on
    @param vInst: VirtualInstance - The virtual instances to read directives from
    @param node: ReconciledNode - The reconciled node to output unmount tasks to

    Reconciles the basic (non-child) directives on a virtual instance during the
    mounting process.
]]
local handleDirective: {[string]: (
    node: ReconciledNode,
    payload: any
) -> ()} = {}
handleDirective.Properties = ApplyPropertyMapThrows
handleDirective.Attributes = ApplyAttributeMapThrows
handleDirective.TagList = ApplyTagListsThrows
handleDirective.Connect = ConnectEventThrows
handleDirective.OutProperty = OutputPropertyThrows
handleDirective.OutAttribute = OutputAttributeThrows
handleDirective.OutInstance = OutputInstanceRefThrows
handleDirective.OnMount = HandleOnMountCallbackThrows
handleDirective.OnUnmount = HandleOnUnmountCallbackThrows
handleDirective.Children = function() end
handleDirective.MapChildren = function() end
handleDirective.MapChildrenByKey = function() end
handleDirective.DestroyPremadeChildren = function() end

-- Set of directives to call once with a list of payloads rather than multiple
-- times with a single payload
local directivesToCollate: {[string]: true} = {}
directivesToCollate.TagList = true
directivesToCollate.Properties = true
directivesToCollate.Attributes = true

-- Priority of directives to process (In range [1, 4], higher processed last)
local typeToPriority: {[string]: (payload: any) -> number} = {
    ["OutProperty"] = function(payload)
        return if payload.once then 1 else 3
    end,
    ["OutAttribute"] = function(payload)
        return if payload.once then 1 else 3
    end,
    ["OutInstance"] = function()
        return 3
    end,
    ["OnMount"] = function()
        return 4
    end,
    ["OnUnmount"] = function()
        return 4
    end,
    ["default"] = function()
        return 2
    end,
}


local function getDirectivePriority(directive: {_type: string, _payload: any})
    local getPriority = typeToPriority[directive._type]
        or typeToPriority.default
    return getPriority(directive._payload)
end

local function ApplyBasicDirectives(
    node: ReconciledNode,
    virtualInstance: VirtualInstance
)
    local directivesByPriority = {{}, {}, {}, {}}
    for _, directive in virtualInstance._directives do
        if not handleDirective[directive._type] then
            error(
                "Reconciler method not implemented yet for directive type '"
                .. directive._type .. "'"
            )
        end
        table.insert(
            directivesByPriority[getDirectivePriority(directive)],
            directive
        )
    end
    for _, directiveList in directivesByPriority do
        local directiveTypeToCollatedPayloads: {[string]: {any}} = {}
        for _, directive in directiveList do
            if directivesToCollate[directive._type] then
                local dirList = directiveTypeToCollatedPayloads[directive._type]
                if not dirList then
                    dirList = {}
                    directiveTypeToCollatedPayloads[directive._type] = dirList
                end
                table.insert(dirList, directive)
                continue
            end
            local handler = handleDirective[directive._type]
            local success, err = pcall(
                handler :: any, node, directive._payload
            )
            if not success then
                EmitTracedError(
                    "Error when mounting VirtualInstance:\n" .. err,
                    directive._trace
                )
            end
        end

        for dirType, dirList in directiveTypeToCollatedPayloads do
            local handler = handleDirective[dirType]
            local success, err = pcall(
                handler :: any, node, dirList
            )
            if not success then
                EmitTracedError(
                    "Error when mounting VirtualInstance:\n" .. err,
                    dirList[1]._trace
                )
            end
        end
    end
end

return ApplyBasicDirectives