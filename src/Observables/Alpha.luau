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
Alpha.__index.Map = Observable.__index.Map
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

local function lerpUsingLinearMath(start: any, finish: any, alpha: number): any
    return start + (finish - start) * alpha
end
local typeToInterpolator: {[string]: (
    start: any,
    finish: any,
    alpha: number
) -> any} = {
    number = lerpUsingLinearMath,
    Vector2 = lerpUsingLinearMath,
    Vector2int16 = lerpUsingLinearMath,
    Vector3 = lerpUsingLinearMath,
    Vector3int16 = lerpUsingLinearMath,
    CFrame = function(a: CFrame, b: CFrame, alpha)
        return a:Lerp(b, alpha)
    end,
    Color3 = function(a: Color3, b: Color3, alpha)
        return a:Lerp(b, alpha)
    end,
    UDim = function(a: UDim, b: UDim, alpha)
        return UDim.new(
            lerpUsingLinearMath(a.Scale, b.Scale, alpha),
            lerpUsingLinearMath(a.Offset, b.Offset, alpha)
        )
    end,
    UDim2 = function(a: UDim2, b: UDim2, alpha)
        return UDim2.new(
            lerpUsingLinearMath(a.X.Scale, b.X.Scale, alpha),
            lerpUsingLinearMath(a.X.Offset, b.X.Offset, alpha),
            lerpUsingLinearMath(a.Y.Scale, b.Y.Scale, alpha),
            lerpUsingLinearMath(a.Y.Offset, b.Y.Offset, alpha)
        )
    end,
    -- Follows the conventions of TweenService. This is useful for tweening:
    -- { Visible = false }
    boolean = function(a: boolean, b: boolean, alpha)
        if a ~= b then
            return alpha < 1
        end
        return a
    end,
    Rect = function(a: Rect, b: Rect, alpha)
        return Rect.new(
            lerpUsingLinearMath(a.Min.X, b.Min.X, alpha),
            lerpUsingLinearMath(a.Min.Y, b.Min.Y, alpha),
            lerpUsingLinearMath(a.Max.X, b.Max.X, alpha),
            lerpUsingLinearMath(a.Max.Y, b.Max.Y, alpha)
        )
    end,
}
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
    local interpolator = typeToInterpolator[typeof(startValue)]
    if not interpolator then
        error("Data type '" .. typeof(startValue) ..
            "' cannot be interpolated!")
    end
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