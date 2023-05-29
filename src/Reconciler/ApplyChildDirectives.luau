--!strict
local Types = require(script.Parent.Parent.Parent.Types)
-- local EmitTracedError = require(script.Parent.EmitTracedError)
type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

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