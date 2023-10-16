--!strict

--[=[
    @function IsVirtualInstance
    @within Dex
    @param passedIn unknown
    @return boolean

    This function checks if the passed in value is a Dex VirtualInstance
]=]
local function IsVirtualInstance(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return (passedIn :: any)._dectype == "VirtualInstance"
end

return IsVirtualInstance