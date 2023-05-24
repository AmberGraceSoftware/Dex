--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type Alpha = Types.Alpha

local Alpha = {}
Alpha.__index = {}
Alpha.__index._dectype = "Observable"
Alpha.__index._decobservabletype = "Alpha"

--[[
    @param startAlpha: number - The start value for the slice.
    @param endAlpha: number - The end value for the slice.
    @return Dec.Alpha - The sliced Alpha Observable.

    Creates a slice of the current Alpha Observable that starts at startAlpha
    (maps to 0) and ends at endAlpha (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]]
function Alpha.__index.Slice(
    self: Alpha,
    startAlpha: number,
    endAlpha: number
): Alpha
    error("Not implemented yet")
end

--[[
    @param easingStyle: Enum.EasingStyle? - Optional easing style.
    @param easingDirection: Enum.EasingDirection? - Optional easing direction.
    @return Dec.Alpha - The interpolated Alpha Observable.

    Creates a new Alpha Observable that interpolates between 0 and one using
    the given easing style and direction. Useful for creating non-linear
    animations.
]]
function Alpha.__index.Interpolate(
    self: Alpha,
    easingStyle: Enum.EasingStyle?,
    easingDirection: Enum.EasingDirection?
): Alpha
    error("Not implemented yet")
end

Alpha.__index.Current = Observable.__index.Current
Alpha.__index.Subscribe = Observable.__index.Subscribe
Alpha.__index.Destroy = Observable.__index.Destroy

--[[
    @param initialValue: number - The initial value for the Alpha Observable.
    @return Dec.Alpha - The new Alpha Observable.

    Creates a new Alpha Observable with the provided initial value.
]]
function Alpha.new(initialValue: number): Alpha
    return setmetatable({
        _current = initialValue,
        _observerCount = 0,
    }, Alpha :: any)
end

return Alpha
