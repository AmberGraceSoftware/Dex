--!strict

--[=[
    @function IsObservable
    @within Dec
    @param passedIn unknown
    @return boolean

    This function checks if the passed in value is an Observable.
]=]
local function IsObservable(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return (passedIn :: any)._dectype == "Observable"
end

return IsObservable