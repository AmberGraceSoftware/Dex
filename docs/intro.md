# Dec Introduction

Dec is a modern reactive UI library for building declarative, stateful, and
animated components that scale for a project's need.

It includes firsthand support for both fully managed UI trees, and templated UI
trees, depending on your project's UI asset development pipeline.

:::caution
Dec is currently in early development, and a stable first release has not been
finished or tested..
:::

Stay tuned for a first stable release, guides, and API finalization!
In the meantime, feel free to share awareness about the project and provide
feedback!

For a sneak peak at the project's paradigm, checkout the
[API Section!](../api/Dec)

### Here's a Hello World written in Dec!
```lua
-- Create our Dec application
local App = Dec.New("ScreenGui", {
    ResetOnSpawn = false
}, {
    HelloLabel = Dec.New("TextLabel", {
        Text = "Hello, World!",
        TextColor3 = Color3.fromHex("000"),
        TextStrokeTransparency = 1
        BackgroundColor3 = Color3.fromHex("ddd"),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(2, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
    }, {
        RoundedRect = Dec.New("UICorner", {
            CornerRadius = UDim.new(0.2, 0)
        })
    })
})

-- Render our Dec application under PlayerGui
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local root = Dec.Root(PlayerGui)
root.Render(App)
```