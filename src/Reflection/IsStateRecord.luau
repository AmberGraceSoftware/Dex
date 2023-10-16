--!strict

--[=[
    @function IsStateRecord
    @within Dex
    @param passedIn unknown
    @return boolean

    This function checks if the passed in value is a [StateRecord] observable
    object
]=]
local function IsStateRecord(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return ((passedIn :: any)._dectype == "Observable")
        and ((passedIn :: any)._decobservabletype == "StateRecord")
end

return IsStateRecord