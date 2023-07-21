# Reactive Time controls

This is a proposal for using reactive time controls for Stopwatch/Timers, since
most of my real use cases have had me wanting to reactively start/stop the timer
rather than procedurally starting/stopping them.

This API change is breaking, and uses props for stopwatches. The new API should
be more consistent with the status quo for `Spring` and `Eased` observables,
which have the same caveats for simulated observable subclasses.

To create a reactively-playing Stopwatch:
```lua
local function OpenAnimation()
    local stopwatch = Dec.Stopwatch({
        playing = props.visible,
        maxDuration = 8,
    })
    local alpha = stopwatch:CurvedAlpha(Enum.EasingStyle.Sine)
    return Dec.Premade("GuiObject", {
        Position = alpha:Lerp(
            UDim2.fromScale(0.5, -0.1),
            UDim2.fromScale(0.5, 0.5)
        ),
        AnchorPoint = alpha:Lerp(
            Vector2.new(0.5, 1),
            Vector2.new(0.5, 0.5),
        ),
    })
end
```

No manual :Start() / :Stop() calls required, or unsafe/hacky `Subscribe` calls!

This will also simplify the hello world:

```lua
--!strict
local Dec = require(game.ReplicatedStorage.Packages.Dec)

local function App()
    return Dec.New("ScreenGui", {}, {
        Label = Dec.New("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            TextSize = 24,
            TextColor3 = Dec.Stopwatch():Map(function(currentTime)
                return Color3.fromHSV((currentTime / 5) % 1, 1, 1)
            end),
            Text = "Hello, World!",
        })
    })
end

local root = Dec.Root(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
root:Render(App())
```

To use time controls, simply create a new dec state:

```lua
local playStopwatch = Dec.State(false)
local stopwatch = Dec.Stopwatch({ playing = playStopwatch})
-- . . .
playStopwatch:Set(true)
```

Or, for more complex time controls:
```lua
local timeControls = Dec.State({
    playing = false,
    paused = false,
    startTime = 0,
})
local stopwatch = Dec.Stopwatch({
    playing = timeControls:Map(function(current)
        return current.playing
    end),
    paused = timeControls:Map(function(current)
        return current.paused
    end),
    startTime = timeControls:Map(function(current)
        return current.startTime
    end),
})

-- . . .
timeControls:Set({
    playing = true,
    paused = false,
    startTime = 0,
})
```

## New API / Props:

```lua
Dec.Stopwatch(props: {
    playing: Dec.CanBeObservable<boolean>?, -- Defaults to true
    paused: Dec.CanBeObservable<boolean>?,
    startTime: Dec.CanBeObservable<number>?,
    maxDuration: Dec.CanBeObservable<number>?, -- Defaults to math.huge
})
```

```lua
Dec.Timer(props: {
    duration: Dec.CanBeObservable<number>,
    playing: Dec.CanBeObservable<boolean>?, -- Defaults to true
    paused: Dec.CanBeObservable<boolean>?,
    startTime: Dec.CanBeObservable<number>?,
})
```

```lua
Dec.Sequence(props: {
    steps: {DecSequenceStep},
    playing: Dec.CanBeObservable<boolean>?, -- Defaults to true
    paused: Dec.CanBeObservable<boolean>?,
    startTime: Dec.CanBeObservable<number>?,
})
```