--!strict
--[[
    Simple library used to create Dex Symbol objects
]]

local Types = require(script.Parent.Parent.Types)

export type Symbol<Name> = Types.Symbol<Name>

local Symbol = {}
Symbol.__index = {}
Symbol.__index._dectype = "Symbol"
function Symbol.__tostring(self: Symbol<any>)
    if self._usage then
        return table.concat({self._name, "\n(Usage: ", self._usage, ")"})
    end
    return self._name
end
function Symbol.__eq(lhs: Symbol<any>, rhs: Symbol<any>): boolean
    if typeof(rhs) ~= "table" then
        return false
    end
    if rhs._dectype ~= "Symbol" then
        return false
    end
    return lhs._name == rhs._name
end

function Symbol.new<Name>(name: Name, usage: string?): Symbol<Name>
    return setmetatable({
        _name = name,
        _usage = usage,
    }, Symbol)
end

return Symbol