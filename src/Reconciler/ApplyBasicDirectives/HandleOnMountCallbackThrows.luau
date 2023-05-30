--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: (instance: any) -> ()
    @return void
    
    Immediately spawns the given OnMount callback with the reconciled instanc
     as an argument
]]
local function HandleOnMountCallbackThrows(
    reconciledNode: ReconciledNode,
    payload: (instance: any) -> ()
)
    task.spawn(payload, reconciledNode._instance :: Instance)
end

return HandleOnMountCallbackThrows