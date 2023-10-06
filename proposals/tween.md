# Proposal: Dec.Clock observable subclass

This is a proposal to add an observable subclass, `Dec.Tween<T>`, which acts
very close to Roblox's Tween API in the domain of a single output property.

Dec also exposes a type called `TweenParams<T>` with the following structure:
```lua
export type TweenParams<T> = {
    info: TweenInfo,
    goal: T
    start: T?
    completed: (() -> ())?,
    cancelled: (() -> ())?,
}
```

Tweens can have params dispatched via an input observer (reactive tweens) or
have them dispatched via a `:Play(params: TweenParams<T>)` (procedural /
event-based logic)

# Status: In Progress

## Use Cases:

Tweens are what Roblox players know, and they are probably more intuitive to use
than any other construct that Dec could provide.

Tweens can be a safe way both to make reactive and event-triggered animations
based on the needs of a UI element.

## Example:

```lua
-- How a Dec Wizard would write this:
local function CollapsibleMenu(props: {
    isCollapsed: Dec.Observable<boolean>,
})
    return Dec.New("Frame")({
        AnchorPoint = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromScale(0.2, 1),
        Position = Dec.Tween(props.isCollapsed:Map(function(isCollapsed)
            return {
                goal = UDim2.fromScale(
                    if isCollapsed then -0.1 else 0.2,
                    0.5
                ),
                info = TweenInfo.new(
                    0.25,
                    Enum.EasingStyle.Quad,
                    if isCollapsed
                        then Enum.EasingDirection.Out
                        else Enum.EasingDirection.In
                )
            }
        end))
    })
end

-- How a beginner Dec user would intuitively write this:
local function CollapsibleMenu(props: {
    isCollapsed: Dec.Observable<boolean>,
})
    local positionTween = Dec.Tween()
    local frame = Dec.New("Frame")({
        AnchorPoint = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromScale(0.2, 1),
        Position = positionTween
    })

    frame:SubscribeWhileMounted(props.isCollapsed, function(isCollapsed)
        if isCollapsed then
            positionTween:Play({
                goal = UDim2.fromScale(-0.1, 0.5)
                info = TweenInfo.new(0.25, Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out)
            })
        else
            positionTween:Play({
                goal = UDim2.fromScale(0.2, 0.5)
                info = TweenInfo.new(0.25, Enum.EasingStyle.Quad,
                    Enum.EasingDirection.In)
            })
        end
    end)
end
```

While the latter example is not the best practice, it's super intuitive for
Roblox users, and would probably see a lot of use if added as a first-class
Observable subclass!