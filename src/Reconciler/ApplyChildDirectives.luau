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
    @param instance: Instance - The instance to apply virtual instance directives on
    @param vInst: VirtualInstance - The virtual instances to read directives from
    @param node: ReconciledNode - The reconciled node to output unmount tasks to

    Reconciles all Child directives on a virtual instance during the mounting
    process.
]]
local function ApplyChildDirectives()
end

return ApplyChildDirectives