--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode
type State<T> = Types.State<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: State<any>
    @return void
    
    Outputs a reference to the reconciled instance, into the state specified in
    the payload.
]]
local function OutputInstanceRefThrows(
    reconciledNode: ReconciledNode,
    payload: {attribute: string, state: State<any>, once: boolean}
)
    payload.state:Set(reconciledNode._instance)
end

return OutputInstanceRefThrows