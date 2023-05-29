--!strict
local Types = require(script.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: (instance: any) -> ()
    @return void
    
    Immediately spawns the given OnMount callback with the reconciled instanc
     as an argument
]]
local function HandleOnUnmountCallbackThrows(
    reconciledNode: ReconciledNode,
    payload: (instance: any) -> ()
)
    local instance = reconciledNode._instance
    table.insert(reconciledNode._unsubscribes, function()
        task.defer(payload, instance)
    end)
end

return HandleOnUnmountCallbackThrows