---
sidebar_position: 3
---

# Hello, World!

Now that Dec is installed, let's try it out with a plussed-up rainbow
"Hello, World!" UI in Roblox Studio!

<video width="100%" controls autoplay muted loop>
  <source src="/helloRainbow.mov" type="video/mp4" />
  ***Your browser does not support HTML Videos.***
  
  ***Please update your browser version and/or download
  [Google Chrome](https://www.google.com/chrome/) to view this page
  correctly.***
</video>

<br/>
<br/>

First, make sure the Dec package is [properly installed](Installation.md) and
located in `game.ReplicatedStorage.Packages.Dec`

Next, in Roblox Studio, create a LocalScript under
`game.StarterPlayer.StarterPlayerScripts` and paste the following:

```lua
--!strict
local Dec = require(game.ReplicatedStorage.Packages.Dec)

local function App()
    local stopwatch = Dec.Stopwatch()
    stopwatch:Start()

    return Dec.New("ScreenGui", {}, {
        Label = Dec.New("TextLabel", {
            Size = UDim2.fromScale(1, 1),
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

The tutorial section will go over how each of Dec's features work together to
help build beautiful and responsive UI components!