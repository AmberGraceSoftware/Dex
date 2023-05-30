--!strict

--[[
    @param passedIn: unknown - The value to check
    @return boolean - Whether or not the passed in value is an Observable.

    This function checks if the passed in value is an Observable.
]]
local function IsObservable(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return (passedIn :: any)._dectype == "Observable"
end

return IsObservable