--!strict
--[[
    Asserts parameters to VirtualInstance:Combine() have a consistent ClassName
    for all combined VirtualInstances at runtime.
]]
local EmitTracedError = require(script.Parent.EmitTracedError)
local Types = require(script.Parent.Parent.Types)

type VirtualInstance = Types.VirtualInstance
type ReconciledNode = Types.ReconciledNode

local function ApplyCombinedIsAChecks(
    node: ReconciledNode,
    virtualInstance: VirtualInstance
)
    if not node._instance then
        return
    end
    if virtualInstance._combinedIsAChecks then
        for _, isACheck in virtualInstance._combinedIsAChecks do
            if not node._instance:IsA(isACheck.className) then
                EmitTracedError(
                    "Error when mounting VirtualInstance: Instance was " .. 
                    "combined with a Premade VirtualInstance with ClassName " ..
                    "'" .. isACheck.className .. "', but the base " .. 
                    "VirtualInstance is a '" .. node._instance.ClassName .. "'",
                    isACheck.trace
                )
            end
        end
    end
end

return ApplyCombinedIsAChecks