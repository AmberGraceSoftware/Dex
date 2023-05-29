--!strict
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type Alpha = Types.Alpha
type Observable<T> = Types.Observable<T>

local Alpha = {}
Alpha.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Alpha.__index :: any)[k] = v
end
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
    return Alpha.new(self, startAlpha, endAlpha)
end

--[[
    @param easingStyle: Enum.EasingStyle? - Optional easing style.
    @param easingDirection: Enum.EasingDirection? - Optional easing direction.
    @return Dec.Alpha - The interpolated Alpha Observable.

    Creates a new Alpha Observable that interpolates between 0 and 1 using
    the given easing style and direction. Useful for creating non-linear
    animations.
]]
function Alpha.__index.Curve(
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
    @return Dec.Alpha - The inverted Alpha Observable.

    Creates a new Alpha Observable that maps 0 to 1 and 1 to 0 from the original
    Observable. Useful for reversing animations, output values, etc.
]]
function Alpha.__index.Invert(
    self: Alpha
): Alpha
    local inverted = MapObservable(
        self,
        function(current)
            return 1 - current
        end
    ) :: any
    setmetatable(inverted, Alpha)
    return inverted
end

--[[
    @param startValue: T - The start value for the lerp.
    @param goalValue: T - The goal value for the lerp.
    @return Observable<T> - The lerped Observable.

    Creates a new Observable that outputs an interpolated value between the 
    start value and goal value based on the current Alpha value.
]]
function Alpha.__index.Lerp<T>(
    self: Alpha,
    startValue: T,
    goalValue: T
): Observable<T>
    local interpolator = PolymorphicLerp(typeof(startValue))
    return MapObservable(
        self,
        function(current)
            return interpolator(startValue, goalValue, current)
        end
    ) :: any
end


--[[
    @param sourceState: Dec.Observable<number> - The source state to derive an alpha from.
    @param sourceRangeMin - The number in source state to maps to 0
    @param sourceRangeMax - The number in source state to maps to 1
    @return Dec.Alpha - The new Alpha Observable.

    Creates a new Alpha Observable with the provided initial value.
]]
function Alpha.new(
    sourceState: Observable<number>,
    sourceRangeMin: number,
    sourceRangeMax: number
): Alpha
    local range = sourceRangeMax - sourceRangeMin
    local self: Alpha = MapObservable(
        sourceState,
        function(sourceCurrent)
            -- Sanitize NaN values
            local nextValue = (sourceCurrent - sourceRangeMin) / range
            if nextValue ~= nextValue then
                return 0
            end

            return math.clamp(
                nextValue,
                0, 1
            )
        end
    ) :: any
    setmetatable(self, Alpha)
    return self
end

return Alpha