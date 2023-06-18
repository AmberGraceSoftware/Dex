--!strict


local function mathExpresionLerp(start: any, finish: any, alpha: number): any
    return start + (finish - start) * alpha
end
local function classMethodLerp(start: any, finish: any, alpha: number): any
    return start:Lerp(finish, alpha)
end
local typeToInterpolator: {[string]: (
    start: any,
    finish: any,
    alpha: number
) -> any} = {
    number = mathExpresionLerp,
    Vector2 = mathExpresionLerp,
    Vector2int16 = mathExpresionLerp,
    Vector3 = mathExpresionLerp,
    -- Vector3int16 doesn't support decimal scalar multiplication the same way
    -- Vector2int16 does for some reason
    Vector3int16 = function(vec3A, vec3B, alpha)
        return Vector3int16.new(
            mathExpresionLerp(vec3A.X, vec3B.X, alpha),
            mathExpresionLerp(vec3A.Y, vec3B.Y, alpha),
            mathExpresionLerp(vec3A.Z, vec3B.Z, alpha)
        )
    end,
    CFrame = classMethodLerp,
    Color3 = classMethodLerp,
    UDim = function(a: UDim, b: UDim, alpha)
        return UDim.new(
            mathExpresionLerp(a.Scale, b.Scale, alpha),
            mathExpresionLerp(a.Offset, b.Offset, alpha)
        )
    end,
    UDim2 = function(a: UDim2, b: UDim2, alpha)
        return UDim2.new(
            mathExpresionLerp(a.X.Scale, b.X.Scale, alpha),
            mathExpresionLerp(a.X.Offset, b.X.Offset, alpha),
            mathExpresionLerp(a.Y.Scale, b.Y.Scale, alpha),
            mathExpresionLerp(a.Y.Offset, b.Y.Offset, alpha)
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
            mathExpresionLerp(a.Min.X, b.Min.X, alpha),
            mathExpresionLerp(a.Min.Y, b.Min.Y, alpha),
            mathExpresionLerp(a.Max.X, b.Max.X, alpha),
            mathExpresionLerp(a.Max.Y, b.Max.Y, alpha)
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