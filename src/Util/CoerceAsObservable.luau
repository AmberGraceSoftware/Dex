--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Parent.Observables.Observable)
local IsObservable = require(script.Parent.IsObservable)

export type Observable<T> = Types.Observable<T>
export type CanBeObservable<T> = Types.CanBeObservable<T>

local function staticUpdateStream()
    return function()
    end
end

--[[
    @param passedIn: unknown - The value to coerce.
    @return Dec.Observable<T> - An Observable.

    This function coerces the passed in value to an Observable. Useful for
    unwrapped the CanBeObservable<T> type in a component's props.
]]
local function CoerceAsObservable<T>(passedIn: CanBeObservable<T>): Observable<T>
    if IsObservable(passedIn) then
        -- Passed in value is already an Observable
        return passedIn :: Observable<T>
    else
        -- Passed in value is a raw value, so create a new Observable
        return Observable.new(
            function()
                return passedIn :: T
            end,
            staticUpdateStream
        )
    end
end

return CoerceAsObservable
