--!strict


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

local function PolymorphicLerp(type: string): <T>(T, T, number) -> T
    local interpolator = typeToInterpolator[type]
    if not interpolator then
        error("Data type '" .. type .. "' cannot be interpolated!")
    end

    return interpolator :: any
end

return PolymorphicLerp