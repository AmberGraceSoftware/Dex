--!strict
local Types = require(script.Parent.Parent.Parent.Types)
type ReconciledNode = Types.ReconciledNode
type State<T> = Types.State<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param payload: {property: string, state: State<any>, once: boolean}
    
    Outputs a property on the reconciled instance to the state specified in the
    payload. If payload.once is true, will only output the property on mount
    one time and no more.
]]
local function OutputPropertyThrows(
    reconciledNode: ReconciledNode,
    payload: {property: string, state: State<any>, once: boolean}
)
    local instance = reconciledNode._instance :: any
    local reconciledConns = reconciledNode._connections

    payload.state:Set(instance[payload.property])

    if not payload.once then
        table.insert(
            reconciledConns,
            instance
                :GetPropertyChangedSignal(payload.property)
                :Connect(function()
                    payload.state:Set(instance[payload.property])
                end)
        )
    end
end

return OutputPropertyThrows