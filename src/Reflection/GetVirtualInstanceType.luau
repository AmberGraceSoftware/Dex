--!strict
local IsVirtualInstance = require(script.Parent.IsVirtualInstance)
local Types = require(script.Parent.Parent.Types)
type VirtualInstance = Types.VirtualInstance
export type VirtualInstanceType = "New" | "Clone" | "Premade"
--[=[
    @function GetVirtualInstanceType
    @within Dec
    @param passedIn VirtualInstance
    @return "New" | "Clone" | "Premade"

    This function returns the constructor type for VirtualInstance ("New",
    "Clone", or "Premade"). Errors if the passed in value is not a
    VirtualInstance.
]=]
local function GetVirtualInstanceType(
    passedIn: VirtualInstance
): VirtualInstanceType
    if not IsVirtualInstance(passedIn) then
        error("Invalid argument #1 to GetVirtualInstanceType " ..
            "(VirtualInstance expected, got " .. typeof(passedIn) .. ")")
    end
    return passedIn._constructorType :: any
end

return GetVirtualInstanceType