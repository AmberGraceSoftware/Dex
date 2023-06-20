--!strict
local Symbol = require(script.Symbol)

type Symbol<Name> = Symbol.Symbol<Name>

--[=[
    @property Nil Symbol<"Nil">
    @within Dec
    Symbol that represents a "Nil" value. Because "nil" values can't be
    represented as values of a Luau table, Dec.Nil can be used in its place.
    Example usage:
    ```lua
    Dec.New("BillboardGui", {
        Adornee =  Dec.Map(props.adornee)(function(adorneeCurrent: Instance?)
            return adorneeCurrent or Dec.Nil
        end)
    })
    ```
]=]
local Symbols = {
    }
    Nil = (Symbol.new(
        "Nil",
        "A value that represents 'nil' when a VirtualInstance is reconciled " ..
        "with Dec. Example usage: `virtualGui:Assign({ Adornee = Dec.Nil })`"
    ) :: any) :: Symbol<"Nil">,
}

return Symbols