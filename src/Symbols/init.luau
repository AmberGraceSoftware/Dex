--!strict
local Symbol = require(script.Symbol)

type Symbol<Name> = Symbol.Symbol<Name>

--[=[
    @prop Nil Symbol<"Nil">
    @within Dex
    Symbol that represents a "Nil" value. Because "nil" values can't be
    represented as values of a Luau table, `Dex.Nil` can be used in its place.
    Example usage:
    ```lua
    return Dex.Premade("BillboardGui", {
        -- Sets the Adornee property of the premade UI to "Nil" on mount
        Adornee = Dex.Nil,
    })
    ```
]=]
local Symbols = {
    Nil = (Symbol.new(
        "Nil",
        "A value that represents 'nil' when a VirtualInstance is reconciled " ..
        "with Dex. Example usage: `virtualGui:Assign({ Adornee = Dex.Nil })`"
    ) :: any) :: Symbol<"Nil">,
}

return Symbols