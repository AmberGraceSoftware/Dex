--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: (instance: any) -> ()
    
    Immediately spawns the given OnMount callback with the reconciled instance
    as an argument
]]
local function HandleOnMountCallbackThrows(
    _reconciledNode: ReconciledNode,
    payload: () -> ()
)
    task.spawn(payload)
end

return HandleOnMountCallbackThrows