--!strict
local Types = require(script.Parent.Parent.Types)
-- local EmitTracedError = require(script.Parent.EmitTracedError)
type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode
type ChildPath = Types.ChildPath

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

--[[
    @param node: ReconciledNode - The reconciled node to apply child directives on
    @param vInst: VirtualInstance - The virtual instances to read directives from
    @param debugLevel: number - The error level to emit any errors when encountered

    Reconciles all Children directives on a virtual instance during the mounting
    process.
]]
local function ApplyChildDirectives(
    node: ReconciledNode,
    virtualInstance: VirtualInstance,
    debugLevel: number
)
    local RenderVirtualInstance = (require :: any)(script.Parent.RenderVirtualInstance)

    error("Not Implemented Yet!")
end

return ApplyChildDirectives