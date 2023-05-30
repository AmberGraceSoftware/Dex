--!strict
local Types = require(script.Parent.Parent.Types)
type VirtualInstanceTrace = Types.VirtualInstanceTrace

--[[
    @param errMessage: string
    @param trace: VirtualInstanceTrace?
    @param debugLevel: number
    @return void

    Emits an error at the given debug level which has a traceback to the
    original VirtualInstance API call that the error can be traced to in the 
    Dec library user's code
]]
local function EmitTracedError(
    errMessage: string,
    trace: VirtualInstanceTrace?,
    debugLevel: number
)
    debugLevel += 1
    local errMessageStrs = {
        errMessage
    }
    if trace then
        table.insert(errMessageStrs, "\n(Traceback:)\n")
        table.insert(errMessageStrs, "\tMethod: ")
        table.insert(errMessageStrs, trace.method)
        for _, traceLevel in trace.traceback do
            table.insert(errMessageStrs, "\n\t")
            if trace.source then
                table.insert(errMessageStrs, trace.source)
            end
            table.insert(errMessageStrs, ":")
            table.insert(errMessageStrs, tostring(traceLevel.line))
            table.insert(errMessageStrs, " function ")
            table.insert(errMessageStrs, traceLevel.identifier)
        end
    end
    error(
        table.concat(errMessageStrs),
        debugLevel
    )
end

return EmitTracedError