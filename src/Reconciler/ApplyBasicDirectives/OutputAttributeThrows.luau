--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode
type State<T> = Types.State<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: {attribute: string, state: State<any>, once: boolean}
    @return void
    
    Outputs a attribute on the reconciled instance to the state specified in the
    payload. If payload.once is true, will only output the attribute on mount
    one time and no more.
]]
local function OutputAttributeThrows(
    reconciledNode: ReconciledNode,
    payload: {attribute: string, state: State<any>, once: boolean}
)
    local instance = reconciledNode._instance
    local reconciledConns = reconciledNode._connections

    payload.state:Set(instance:GetAttribute(payload.attribute))

    if not payload.once then
        table.insert(
            reconciledConns,
            instance
                :GetAttributeChangedSignal(payload.attribute)
                :Connect(function()
                    payload.state:Set(instance:GetAttribute(payload.attribute))
                end)
        )
    end
end

return OutputAttributeThrows