--!strict
--[[
    Utility function which subscribes to an observable, which may in turn return
    another observable, and so on. Immediately calls the listener once as well
    as subscribing to changes.

    Will unwrap each chained observable value until a non-observable value is
    resolved.

    Returns a single "unsubscribe" function which unsubscribes the entire
    observable chain.
]]
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
local Types = require(script.Parent.Parent.Types)
type Observable<T> = Types.Observable<T>

local function ChainedSubscribe(
    input: Observable<any>,
    callback: (any) -> ()
): () -> ()
    local innerCleanup: (() -> ())?
    local outerCleanup = input:Subscribe(function(value)
        if innerCleanup then
            innerCleanup()
            innerCleanup = nil
        end
        if IsObservable(value) then
            innerCleanup = ChainedSubscribe(
                value,
                callback
            )
        else
            callback(value)
        end
    end, true)

    return function()
        outerCleanup()
        if innerCleanup then
            innerCleanup()
        end
    end
end

return ChainedSubscribe