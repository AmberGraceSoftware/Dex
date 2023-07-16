---
sidebar_position: 1
---

# Introduction

:::warning
Dec is still a work in progress and does not currently have a full release!
Please avoiding Dec in production-bound projects, as the library is not fully
tested, and the API may be subject to change
:::

<p className="highlight-paragraph">
Dec is a library for building the User Interfaces of Roblox projects. Dec makes
it simple to write Components—smaller pieces of code responsible for specific
portions of UI—which can work together to build the interface for a complete
Roblox experience.
</p>

<div style={{"display":"block", "margin-right":"7.5%", "margin-left":"3%"}}>
    <span style={{"display": "flex", "align-items": "center",
    "justify-content":"space-between"}}>
        <h4><i>Install Dec inside your project:&nbsp;&nbsp;</i></h4>
        <div class="cta-button">
            <a class="button button--primary button-lg" href="./Installation" 
            style={{"display":"block", "width":"11.5em"}}>
                Installation → 
            </a>
        </div>
    </span>
    <span style={{"display": "flex", "align-items": "center",
    "justify-content":"space-between"}}>
        <h4><i>Learn the basics of Dec:&nbsp;&nbsp;</i></h4>
        <div class="cta-button">
            <a class="button button--primary button-lg"
            href="./Chapter1/VirtualInstance"
            style={{"display":"block", "width":"11.5em"}}>
                Tutorials → 
            </a>
        </div>
    </span>
    <span style={{"display": "flex", "align-items": "center",
    "justify-content":"space-between"}}>
        <h4><i>Read the full documentation:&nbsp;&nbsp;</i></h4>
        <div class="cta-button">
            <a class="button button--primary button-lg" href="../api/Dec"
            style={{"display":"block", "width":"11.5em"}}>
                API Reference → 
            </a>
        </div>
    </span>
</div>

---

<h2 className="less-top-margin">
    Animated "Hello World" Using Dec:
</h2>


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

<video className="align-center" width="90%" controls autoplay muted loop>
    <source src="/helloRainbow.mov" type="video/mp4" />
    ***Your browser does not support HTML Videos.***
    
    ***Please update your browser version and/or download
    [Google Chrome](https://www.google.com/chrome/) to view this page
    correctly.***
</video>

<center>
    <i>
        (Paste the example code into LocalScript under
        `game.StarterPlayer.StarterPlayerScripts`)
    </i>
</center>