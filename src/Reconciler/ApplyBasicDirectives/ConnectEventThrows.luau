--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: {event: string, listener: (...any) -> ()}

    Connects an event listener to an event on the reconciled instance. If an
    error occurs, it should be logged to the console traced to the line of code
    where VirtualInstance:Connect or VirtualInstance:SetProperties was called.
]]
local function ConnectEventThrows(
    reconciledNode: ReconciledNode,
    payload: {event: string, listener: (...any) -> ()}
)
    local instance = reconciledNode._instance :: any
    local reconciledConns = reconciledNode._connections
    table.insert(
        reconciledConns,
        instance[payload.event]:Connect(payload.listener)
    )
end

return ConnectEventThrows