--!strict
local TweenService = game:GetService("TweenService")
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)
local MapObservable = require(script.Parent.Parent.Util.MapObservable)
local PolymorphicLerp = require(script.Parent.Parent.Util.PolymorphicLerp)

type Alpha = Types.Alpha
type Observable<T> = Types.Observable<T>

--[=[
    @class Alpha
    @tag Observable

    #### Inherits [Observable]

    Observable object which maps another numeric observable to the range [0, 1]
    
    Contains helper functions for makinganimations and state transitions.

    ## Constructor
    
    ---

    ### Dec.Alpha
    ```lua
    Dec.Alpha(
        source: Observable<number>,
        sourceRangeMin: number,
        sourceRangeMax: number
    ) -> Alpha
    ```

    Creates a new [Alpha] Observable object, which maps the current value of the
    source observable to the range [0, 1] based on where the source value falls
    between sourceRangeMin and sourceRangeMax
]=]
local Alpha = {}
-- Inherits Observable metamethods
for k, v in Observable :: any do
    if k:sub(1, 2) ~= "__" then
        continue
    end
    (Alpha :: any)[k] = v
end
Alpha.__index = {}
-- Inherits Observable
for k, v in Observable.__index :: any do
    (Alpha.__index :: any)[k] = v
end
Alpha.__index._decobservabletype = "Alpha"

--[=[
    @method Slice
    @within Alpha
    @param startAlpha number
    @param endAlpha number
    @return Alpha

    Creates a slice of the current Alpha Observable that starts at startAlpha
    (maps to 0) and ends at endAlpha (maps to 1).

    Useful for slicing up animation sequences into smaller slices.
]=]
function Alpha.__index.Slice(
    self: Alpha,
    startAlpha: number,
    endAlpha: number
): Alpha
    return Alpha.new(self, startAlpha, endAlpha)
end

--[=[
    @method Curve
    @within Alpha
    @param easingStyle Enum.EasingStyle?
    @param easingDirection Enum.EasingDirection?
    @return Alpha

    Creates a new Alpha Observable that interpolates between 0 and 1 using
    the given easing style and direction. Useful for creating non-linear
    animations.
]=]
function Alpha.__index.Curve(
    self: Alpha,
    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection?
): Alpha
    local interpolated = MapObservable(self)(function(current)
        local tweened = TweenService:GetValue(
            current,
            easingStyle,
            easingDirection or Enum.EasingDirection.Out
        )
        if tweened ~= tweened then
            return 0
        end

        return math.clamp(tweened, 0, 1)
    end) :: any
    setmetatable(interpolated, Alpha)
    return interpolated
end


--[=[
    @method Invert
    @within Alpha
    @return Alpha

    Creates a new Alpha Observable that maps 0 to 1 and 1 to 0 from the original
    Observable. Useful for reversing animations, output values, etc.
]=]
function Alpha.__index.Invert(
    self: Alpha
): Alpha
    local inverted = MapObservable(self)(function(current)
        return 1 - current
    end) :: any
    setmetatable(inverted, Alpha)
    return inverted
end

--[=[
    @method Lerp
    @within Alpha
    @param startValue T
    @param goalValue T
    @return Observable<T> - The lerped Observable.

    Creates a new Observable that outputs an interpolated value between the 
    start value and goal value based on the current Alpha value.
]=]
function Alpha.__index.Lerp<T>(
    self: Alpha,
    startValue: T,
    goalValue: T
): Observable<T>
    local interpolator = PolymorphicLerp(typeof(startValue))
    return MapObservable(self)(function(current)
        return interpolator(startValue, goalValue, current)
    end) :: any
end


--[=[
    @function Alpha
    @within Dec
    @param source Observable<number>
    @param sourceRangeMin number
    @param sourceRangeMax number
    @return Alpha

    Creates a new Alpha Observable object, which maps the current value of the
    source observable to the range [0, 1] based on sourceRangeMin and
    sourceRangeMax
]=]
function Alpha.new(
    sourceState: Observable<number>,
    sourceRangeMin: number,
    sourceRangeMax: number
): Alpha
    local range = sourceRangeMax - sourceRangeMin
    local self: Alpha = MapObservable(sourceState)(function(sourceCurrent)
        -- Sanitize NaN values
        local nextValue = (sourceCurrent - sourceRangeMin) / range
        if nextValue ~= nextValue then
            return 0
        end

        return math.clamp(
            nextValue,
            0, 1
        )
    end) :: any
    setmetatable(self, Alpha)
    return self
end

return Alpha