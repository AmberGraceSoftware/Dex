--!strict
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)

type Alpha = Types.Alpha
type Observable<T> = Types.Observable<T>

local Alpha = {}
Alpha.__index = {}
Alpha.__index.Current = Observable.__index.Current
Alpha.__index.Subscribe = Observable.__index.Subscribe
Alpha.__index.Destroy = Observable.__index.Destroy
Alpha.__index._dectype = Observable.__index._dectype
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
    return Alpha.new(self, NumberRange.new(startAlpha, endAlpha))
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
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha
    local interpolated = MapObservable(
        self,
        function(current)
            local tweened = TweenService:GetValue(
                current,
                easingStyle,
                easingDirection or Enum.EasingDirection.Out
            )
            if tweened ~= tweened then
                return 0
            end

            return math.clamp(tweened, 0, 1)
        end
    ) :: any
    setmetatable(interpolated, Alpha)
    return interpolated
end


--[[
    @param sourceState: Dec.Observable<number> - The source state to derive an alpha from.
    @param sourceRange: NumberRange - The range of the source state to map to the range [0, 1].
    @return Dec.Alpha - The new Alpha Observable.

    Creates a new Alpha Observable with the provided initial value.
]]
function Alpha.new(
    sourceState: Observable<number>,
    sourceRange: NumberRange
): Alpha
    local self: Alpha = MapObservable(
        sourceState,
        function(sourceCurrent)
            if sourceCurrent ~= sourceCurrent then
                return 0
            end

            return math.clamp(
                (sourceCurrent - sourceRange.Min)
                    / (sourceRange.Max - sourceRange.Min),
                0, 1
            )
        end
    ) :: any
    setmetatable(self, Alpha)
    return self
end

return Alpha