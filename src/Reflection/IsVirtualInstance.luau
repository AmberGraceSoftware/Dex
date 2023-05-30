--!strict

--[[
    @param passedIn: unknown - The value to check
    @return boolean - Whether or not the passed in value is a VirtualInstance

    This function checks if the passed in value is a Dec VirtualInstance
]]
local function IsVirtualInstance(passedIn: unknown): boolean
    if typeof(passedIn) ~= "table" then
        return false
    end

    return (passedIn :: any)._dectype == "VirtualInstance"
end

return IsVirtualInstance