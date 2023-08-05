---
sidebar_position: 4
---

# Virtual Instances

## Before We Begin...

See the [Installation Section](../Installation) to make sure Dec is properly
installed in your Roblox experience.

## UI Components

At its heart, Dec is a language for writing ***Components***. Components are
portions of code responsible for specific portions of UI. Building a
large-scale user interface with Dec requires breaking it down into small
building blocks.

To illustrate this, imagine a Roblox game displays a shop menu to the player
upon speaking to an NPC. The menu which pops up might look something like this:

![NPC Shop](/TutorialAssets/Chapter1/VirtualInstance/GecsSeafaringSupplies.jpg)

This menu contains different visual elements, which can be grouped together
based on location and shared function:

![NPC Shop UI Breakdown](/TutorialAssets/Chapter1/VirtualInstance/GecsSeafaringSuppliesComponentBreakdown.jpg)

In Dec, Components are *functions*, named in `PascalCase`, which output a
description of how a piece of UI is put together given some input parameters.

In the example of the NPC shop menu, the whole menu can be represented as 6 Dec
Components:

- `ShopHeader` - Shows the current display name for the NPC's shop
- `CoinCounter` - Displays many coins the user has
- `TextButton` - Displays certain text, darkens in color when hovered/pressed,
and performs some action when clicked on.
- `ShopItems` - Manages which shop items are appearing to the user at a time,
and decides what happens when the left/right buttons are pressed.
- `ShopItem` - Displays info about a single ingame item—its cost, a thumbnail,
and a display name—and performs some action when the circle is clicked on.
- `NPCShop` - A top-level component that generates all of these UI elements
at once!

![NPC Shop Component Breakdown](/TutorialAssets/Chapter1/VirtualInstance/GecsSeafaringSuppliesComponentBreakdown2.jpg)

## `CoinCointer` Component

Let's write a component for the Coin counter in the above example. In Dec,
instances are not directly created using `Instance.new`; instead, Dec utilizes
***Virtual Instances*** to describe how a UI component is pieced together.

The `CoinsCounter` needs to generate two Instances: a `TextLabel` and an
`ImageLabel` We will represent these as ***Virtual Instances*** using
`Dec.New`, which takes a class name and a table of properties as arguments.

```lua
local coinsLabel = Dec.New("TextLabel", {
    Text = "42",
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 252, 238),
    Font = Enum.Font.Antique,
    TextXAlignment = Enum.TextXAlignment.Right,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(0.675, 1),
})
```

```lua
local coinsIcon = Dec.New("ImageLabel", {
    Image = "rbxassetid://14319400598",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(0.8, 0.8),
    SizeConstraint = Enum.SizeConstraint.RelativeYY,
    Position = UDim2.fromScale(0.7, 1),
    AnchorPoint = Vector2.new(0, 1),
})
```

To embed the image and text labels within a frame, we can pass a third
*children* argument to `Dec.New`, which is a table where the keys are the name
of the child, and the values are the virtual instance to embed under the parent:

```lua
local coinCointer = Dec.New("Frame", {
    Size = UDim2.fromScale(0.3, 0.4),
    Position = UDim2.fromScale(1, 0.5),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1,
}, {
    CoinsLabel = coinsLabel,
    CoinsIcon = coinsCointer,
})
```

In order to truly make this into a ***Dec Component***, the virtual instance
should be wrapped in a function. We will also need to create a [Root](/api/Root)
object to actually render the virtual instances:
```lua
local function CoinCointer()
    return Dec.New("Frame", {
        Size = UDim2.fromScale(0.3, 0.4),
        Position = UDim2.fromScale(1, 0.5),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
    }, {
        CoinsLabel = Dec.New("TextLabel", {
            Text = "42",
            TextScaled = true,
            TextColor3 = Color3.fromRGB(255, 252, 238),
            Font = Enum.Font.Antique,
            TextXAlignment = Enum.TextXAlignment.Right,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.675, 1),
        }),
        CoinsIcon = Dec.New("ImageLabel", {
            Image = "rbxassetid://14319400598",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.8, 0.8),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Position = UDim2.fromScale(0.7, 1),
            AnchorPoint = Vector2.new(0, 1),
        }),
        -- Make the component look consistent on different screens
        AspectRatio = Dec.New("UIAspectRatioConstraint", {
            AspectRatio = 4,
        })
    })
end

-- Here, we define a top-level component which holds our CoinCointer
local function Gui()
    return Dec.New("ScreenGui", {
        ResetOnSpawn = false,
    }, {
        CoinCointer = CoinCointer(),
    })
end

-- root:Render() tells Dec to convert out VirtualInstances into real instances
local root = Dec.Root(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
root:Render(Gui())
```

When playtesting with the above code in a LocalScript, the coins component will
render with a static "42" being displayed.

![Coin Counter Ingame](/TutorialAssets/Chapter1/VirtualInstance/CoinCounterIngame.jpg)

## Using Premade templates

Going back to the CoinCointer component, there's a lot of information being
defined in code that is already easy to create in Roblox Studio's UI editor.

Dec is versatile in that it allows three types of VirtualInstances: `New`,
`Clone`, and `Premade`.

- `New` Virtual Instances are created by the Dec library itself, as seen in the
previous example.

- `Clone` Virtual Instances are also created by Dec, but are created created by
copying an existing template, passed in as the first argument to `Dec.Clone()`

- `Premade` Virtual Instances, on the other hand, are only *modified* by Dec,
without creating or destroying any additional instance.

Going back to the `CoinCointer` component, we can greatly simplify the code by
represent our component as a tree of `Premade` Virtual Instances, using this
downloadable template:

<a href="/TutorialAssets/Chapter1/VirtualInstance/PremadeCoinCounter.rbxmx" download target="_blank">(Premade Template Download)</a>

This can be placed directly in StarterGui and used by Dec:

![Premade Coin Counter UI in StarterGui](/TutorialAssets/Chapter1/VirtualInstance/PremadeCoinCounterScreenshot.jpg)

Once the template is in place, the CoinCounter component code can be greatly
simplified!

```lua
local function CoinCointer()
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = "42",
        })
    })
end

local function Gui()
    return Dec.Premade("ScreenGui", {}, {
        CoinCointer = CoinCointer(),
    })
end

local Root = Dec.Root(game.Players.LocalPlayer
	:WaitForChild("PlayerGui"):WaitForChild("PremadeGui"))
Root:Render(Gui())
```

When playtested, this will change the number of coins in our template to `42`,
without needing to worry about the specifics of how the rest of the UI looks!

The next step is to render the actual number of coins the player has by
utilizing ***States***, which will be covered in the next section.

----

*[Coin icon created by Freepik - Flaticon.](https://www.flaticon.com/free-icons/coin)*

*Assets provided for download in this article are provided for educational
purposes only. License is not extended by the maintainers of Dec to use the
provided coin icon in any project, and is subject to FlatIcon's original
[license agreement](https://www.freepikcompany.com/legal#nav-flaticon-agreement)*