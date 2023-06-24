# Hello, World!

Now that Dec is installed, let's build a simple Roblox UI.

First create a LocalScript under `game.StarterPlayer.StarterPlayerScripts`

Add an import and `--strict` mode directive and import to utilize Dec's library and types: 

```lua
--!strict
local Dec = require(game.ReplicatedStorage.Packages.Dec)
```

Finally paste the following code in a LocalScript:

```lua
-- Create our Dec application
local App = Dec.New("ScreenGui", {ResetOnSpawn = false}, {
    HelloLabel = Dec.New("TextLabel", {
        Text = "Hello, World!",
        TestSize = 24,
        BackgroundTransparency = 1, 
        TextColor3 = Color3.fromHex("000"),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
})

-- Render our Dec application under PlayerGui when it loads
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local root = Dec.Root(PlayerGui)
root.Render(App)
```

A simple Dec application will render upon playtesting in Roblox Studio!

Up Next: [Writing a VirtualInstance Tree](./VirtualInstance.md)