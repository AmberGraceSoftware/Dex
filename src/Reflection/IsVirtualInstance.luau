--!strict

--[=[
    @function IsVirtualInstance
    @within Dec
    @param passedIn unknown
    @return boolean

    This function checks if the passed in value is a Dec VirtualInstance
]=]
local function IsVirtualInstance(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return (passedIn :: any)._dectype == "VirtualInstance"
end

return IsVirtualInstance