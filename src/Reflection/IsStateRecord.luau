--!strict

--[[
    @param passedIn: unknown - The value to check
    @return boolean - Whether or not the passed in value is a Dec.StateRecord objec

    This function checks if the passed in value is a Dec.StateRecord observable
    object
]]
local function IsStateRecord(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return ((passedIn :: any)._dectype == "Observable")
        and ((passedIn :: any)._decobservabletype == "StateRecord")
end

return IsStateRecord