--!strict

--[=[
    @function IsState
    @within Dec
    @param passedIn unknown
    @return boolean

    This function checks if the passed in value is a [State] observable object
]=]
local function IsState(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return ((passedIn :: any)._dectype == "Observable")
        and ((passedIn :: any)._decobservabletype == "State")
end

return IsState