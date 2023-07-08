---
sidebar_position: 3
---

# Hello, World!

Now that Dec is installed, let's try it out with an animated "Hello, World!" UI!

First, make sure the Dec package is located at
`game.ReplicatedStorage.Packages.Dec`

Next, in Roblox Studio, create a LocalScript under
`game.StarterPlayer.StarterPlayerScripts` and paste the following code:

```lua
--!strict
local Dec = require(game.ReplicatedStorage.Packages.Dec)

local function App()
    local stopwatch = Dec.Stopwatch()
    stopwatch:Start()

    return Dec.New("ScreenGui", {ResetOnSpawn = false}, {
        Label = Dec.New("TextLabel", {
            Position = UDim2.fromScale(0.5, 0.25),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextSize = 24,
            TextColor3 = stopwatch:Map(function(currentTime)
                return Color3.fromHSV((currentTime / 5) % 1, 1, 1)
            end),
            Text = "Hello, World!",
        })
    })
end

local root = Dec.Root(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
root:Render(App())
```

This will cause rainbow text label to appear on-screen when running a Play Solo
test!

<video width="100%" controls autoplay loop>
  <source src="../../helloRainbow.mov" type="video/mp4" />
  ***Your browser does not support HTML Videos.***
  
  ***Please update your browser version and/or download
  [Google Chrome](https://www.google.com/chrome/) to view this page
  correctly.***
</video>