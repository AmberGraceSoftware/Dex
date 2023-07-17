---
sidebar_position: 4
---

# Virtual Instances

:::warning
Tutorials are still in progress, and will be released section-by-section
:::

## Installation

See the [Installation Section](../Installation) to get started with Dec!

## UI Components

At its heart, Dec is a language for writing ***Components***. Components are
portions of code responsible for specific portions of UI, and building a
large-scale user interface with
Dec requires thinking in terms of *Components*.

To illustrate this, imagine a Roblox game displays a shop menu to the player
upon speaking to an NPC. The modal which pops up might look something like this:

(Image of Gec the Buccaneer UI)

We can group this UI into logical parts responsible for different tasks:

(Image of Component Breakdown)

Dec takes on a *modular* approach to UI development, where each logical part
of an application are grouped together into separate Component functions, with
these functions often being placed inside their own ModuleScript.

## "CoinCointer" Component

Let's write a component for the Coin counter in the above example. In Dec, we do
not directly create instances using `Instance.new` but rather use
***Virtual Instances*** to describe how to put together a particular UI
component.

The CoinsCounter should generate a UI that includes a TextLabel and ImageLabel
inside a larger Frame. We will create each of these using `Dec.New`, passing in
the ClassName as the first argument, and a table of properties as a second
argument:

```lua
local coinsLabel = Dec.New("TextLabel", {
    Text = "42",
    TextScaled = true,
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(0.6, 0),
})
```

```lua
local coinsIcon = Dec.New("ImageLabel", {
    Image = "rbxassetid://12345678",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(0.4, 0.4),
    SizeConstraint = Enum.SizeConstraint.RelativeYY
    Position = UDim2.fromSCale(0.7, 0)
})
```

To embed the image and text labels within a frame, we can pass a third
*children* argument to `Dec.New`, which is a table where the keys are the name
of the child, and the values are the virtual instance to embed under the parent:

```lua
local coinCointer = Dec.New("Frame", {
    Size = UDim2.fromScale(0.2, 0.2),
    Position = UDim2.fromScale(1, 0),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
}, {
    CoinsLabel = coinsLabel,
    CoinsIcon = coinsCointer,
})
```

Finally, to make this into a Component and test it out, we can simply wrap it
into a function which returns the VirtualInstance tree. We will also need to
create a ***Root*** to actually render the component:
```lua
local function CoinCointer()
    return Dec.New("Frame", {
        Size = UDim2.fromScale(0.3, 0.4),
        Position = UDim2.fromScale(1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
    }, {
        CoinsLabel = Dec.New("TextLabel", {
            Text = "42",
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Right
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0.6, 1),
        })
        CoinsIcon = Dec.New("ImageLabel", {
            Image = "rbxassetid://12345678",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY
            Position = UDim2.fromSCale(0.7, 0)
        }),
        -- Make the component look consistent on different screens
        AspectRatio = Dec.New("UIAspectRatioConstraint", {
            AspectRatio = 4,
        })
    })
end

-- Here, we define a top-level component which holds our CoinCointer
local function Gui()
    return Dec.New("ScreenGui", {}, {
        CoinCointer = CoinCointer(),
    })
end

local Root = Dec.Root(game.Players:WaitForChild("PlayerGui"))
Root:Render(Gui())
```

When playtesting with the above code in a LocalScript, the coins component will
render with a static "42" being displayed. Later in this section, we will go
over how to render ***States*** such as coins in our virtual instance.

(image of CoinCointer in game)

## Using Premade templates

Going back to the CoinCointer component, there's a lot of information being
defined in code that is already easy to create in Roblox Studio's UI editor.

Dec is versatile in that it allows three types of VirtualInstances: `New`,
`Clone`, and `Premade`.

`New` Virtual Instances are created by the Dec library itself, as seen in the
previous example.

`Clone` Virtual Instances are also created by Dec, but are created created by
copying an existing template, passed in as the first argument to `Dec.Clone()`

`Premade` Virtual Instances, on the other hand, are only *modified* by Dec, and
simply modify an existing virtual instance.

Going back to the `CoinCointer` component, we can greatly simplify the code by
represent our component as a tree of `Premade` Virtual Instances, using this
downloadable template:

(Download)

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

local Root = Dec.Root(game.Players:WaitForChild("PlayerGui"))
Root:Render(Gui())
```

When playtested, this will change the number of coins in our template to `42`,
without needing to affect other values!

The next step is to render the actual number of coins the player has by
utilizing ***State***, which will be covered in the next section.