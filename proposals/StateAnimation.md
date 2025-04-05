# StateAnimation

StateAnimation is a simple construct designed to "proceduralize" animations in Dex. Often times, procedural code is a much easier way to conceptualize, implement, and reason about animations.

The name "StateAnimation" implies that you are "animating a state", allowing Dex's observable abstraction patterns to shine, and separating concerns in a neat way.

## Constructor

The StateAnimation constructor takes in the following parameters:
```lua
Dex.StateAnimation<T, ...PlayArgs>(
    defaultState: T,
    animation: (setState: (T) -> (), previousState: T, ...PlayArgs) -> ()
) -> Dex.StateAnimation<T, ...PlayArgs>
```
Which is inherits `Dex.Observable<T>`

Example:
```luau
-- StateAnimation takes in an initial state, and a function generator.
-- The animation thread is cancelled via `task.cancel`, allowing yielding
-- within the animation function.
local fadeAndSlideIn = Dex.StateAnimation(
    {
        Position = Vector2.new(0.5, 0.5),
        Transparency = 1
    },
    function(setState, previousState, goalPoint: Vector2)
        local startPos = initialState.Position
        local startTrans = initialState.Transparency
        local goalTrans = 0
        
        local alpha = 0
        while alpha < 1 do
            alpha += RunService.RenderStepped:Wait() / 3
            alpha = math.clamp(alpha, 0, 1)
            local alphaSinCurved = TweenService:GetValue(
                alpha,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            )
            setState({
                Transparency = startTrans + (goalTrans - startTrans) * alpha,
                Position = startPos + (goalPos - startPos) * alphaSinCurved
            })
        end
    end,
end)

-- "fadeAndSlideIn" can be played, paused, and stop at any time
-- (e.g. on component mount)
fadeAndSlideIn:Play(Vector2.new(0.75, 0.9))
task.delay(2, function()
    fadeAndSlideIn:Pause()
    task.wait(2)
    fadeAndSlideIn:Stop()
end)

-- The state animation can be re-mapped to various properties on a
-- VirtualInstance.
local vInst = Dex.Premade("Frame", {
    BackgroundTransparency = fadeAndSlideIn:Map(function(state)
        return state.Transparency,
    end),
    Position = fadeAndSlideIn:Map(function(state)
        return state.Position,
    end),
    AnchorPoint = fadeAndSlideIn:Map(function(state)
        return Vector2.one - state.Position,
    end),
})
```
