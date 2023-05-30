--!strict

--[[
    @param passedIn: unknown - The value to check
    @return boolean - Whether or not the passed in value is a Dec.State object

    This function checks if the passed in value is a Dec.State observable object
]]
local function IsState(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return ((passedIn :: any)._dectype == "Observable")
        and ((passedIn :: any)._decobservabletype == "State")
end

return IsState