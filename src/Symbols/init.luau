--!strict
local Symbol = require(script.Symbol)

type Symbol<Name> = Symbol.Symbol<Name>

local Symbols = {
    Nil = (Symbol.new(
        "Nil",
        "A value that represents 'nil' when a VirtualInstance is reconciled " ..
        "with Dec. Example usage: `virtualGui:Assign({ Adornee = Dec.Nil })`"
    ) :: any) :: Symbol<"Nil">,
}

return Symbols