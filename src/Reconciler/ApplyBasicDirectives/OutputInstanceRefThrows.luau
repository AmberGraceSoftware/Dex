--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode
type State<T> = Types.State<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: State<any>
    
    Outputs a reference to the reconciled instance, into the state specified in
    the payload.
]]
local function OutputInstanceRefThrows(
    reconciledNode: ReconciledNode,
    payload: State<any>
)
    payload:Set(reconciledNode._instance :: Instance)
end

return OutputInstanceRefThrows