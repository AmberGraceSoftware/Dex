--!strict
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)
type Observable<T> = Types.Observable<T>

--[=[
    @function FlattenObservable
    @within Dex
    @param observable Observable<any>
    @return Observable<any>

    If an Observable's current value can be another Observable object, flattens
    the final resolved value of the last returned Observable in the chain,
    and automatically subscribes to any observables returned in the chain.

    Example:
    ```lua
    local coins = Dex.State(Dex.State(3))
    local coinsFlattened = Dex.FlattenObservable(coins)
    print(coinsFlattened:Current()) -- 3

    coins:Set(Dex.State(5))
    print(coinsFlattened:Current()) -- 5

    coins:Current():Set(7)
    print(coinsFlattened:Current()) -- 7
    ```
]=]
local function FlattenObservable(observable: Observable<any>): Observable<any>
    local lastInnerObservable: Observable<any>? = nil
    local lastInnerObservableFlattened: Observable<any>? = nil
    local activeNotifyUpdate: (() -> ())? = nil
    local unsubscribeInner: (() -> ())? = nil
    local function getCurrent()
        local currentRaw = observable:Current()
        local nextInnerObservable: Observable<any>?
        if IsObservable(currentRaw) then
            nextInnerObservable = currentRaw
        end
        if lastInnerObservable ~= nextInnerObservable then
            lastInnerObservable = nextInnerObservable
            lastInnerObservableFlattened = nil
            if unsubscribeInner then
                unsubscribeInner()
                unsubscribeInner = nil
            end
            if nextInnerObservable then
                local flattened = FlattenObservable(nextInnerObservable)
                lastInnerObservableFlattened = flattened

                if activeNotifyUpdate then
                    unsubscribeInner = flattened:Subscribe(
                        activeNotifyUpdate,
                        false
                    )
                end
            end
        end
        if lastInnerObservableFlattened then
            return lastInnerObservableFlattened:Current()
        end
        return currentRaw
    end

    return Observable.new(getCurrent, function(notifyUpdate: () -> ())
        activeNotifyUpdate = notifyUpdate
        if lastInnerObservableFlattened then
            unsubscribeInner = lastInnerObservableFlattened:Subscribe(
                notifyUpdate,
                false
            )
        end
        local unsubscribeOuter = observable:Subscribe(notifyUpdate, false)
        return function()
            activeNotifyUpdate = nil
            if unsubscribeInner then
                unsubscribeInner()
                unsubscribeInner = nil
            end
            unsubscribeOuter()
        end
    end)
end

return FlattenObservable
