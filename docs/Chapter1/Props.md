---
sidebar_position: 7
---

# Passing in Props

The previous two sections covered the fundamentals of
[Virtual Instances](./VirtualInstance) and [State](./State), and how to use them
to write UI components.

This section will go over some ideas on how to _scale up_ many components in an
application to meet a project's needs, and some best practices for doing so.

----

## What are Props?

Props are a simply a table of properties passed in as the only argument for a
Dec component. The concept of props comes from primarily from the JavaScript
framework [React](https://react.dev/learn/passing-props-to-a-component), and is
used in Dec in a similar but slightly different way.

When creating a new ***Virtual Instance***, Dec accepts a properties table,
which can take in both static values and states to define how the object is put
together:

```lua
local function Button()
    local buttonText = Dec.State("Click Me!")
    return Dec.New("TextButton", {
        Activated = function()
            buttonText:Set("Button was clicked!")
        end,
        Text = buttonText,
        BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromHex("fff"),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromScale(0.5, 0.1),
        TextScaled = true,
    }, {
        Dec.New("UICorner", {
            CornerRadius = UDim.new(0.5, 0)
        })
    })
end
```

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/ClickyButton.gif" />
</center>

The above example shows [Dec.New](/api/Dec#New) taking in three different types
of properties:

- **Static Values** (e.g. `number`, `UDim2`, `Vector2`, and `Color3` values)
- **Callbacks** (e.g. connecting to the "Activated" event)
- **States** (e.g. `buttonText`)

In much the same way that Dec allows you to define a virtual instance using a
table of _properties_, you can do the same thing in your Dec components by
including a single argument named _props_

----

## Defining Props in a Component

Let's make the above example a bit more abstract, allowing for the `Button`
component function to be instantiated multiple times.

Let's first lay out some design requirements:
- Each button should have a different _text_ value, which can _change over time_
- Each button should have a different _position_
- Each button should _do something different_ when clicked.

Let's convert these design requirements into a _props_ table:

```lua
local function Button(props: {
    text: Dec.Observable<string>,
    position: UDim2,
    activated: () -> (),
})
```

Here, we defined the structure of our props table using a _type annotation_. Dec
makes use of [Luau's Static Type System](https://luau-lang.org/typecheck), and
it is recommended to give type annotations to the parameters of Dec Components,
with `--!strict` mode enabled where possible. The type annotation in the above
example defines the following values in a _props_ table:

- `text`: An ***Observable string*** representing the current text to
display in the button, which may change over time.
- `position`: A ***static UDim2 value***, representing where the button should
be positioned.
- `activated`: A ***callback function*** which is called whenever the button is
clicked.

The original component can now be refactored to utilize the three values we
defined in props, as well as utilizing a
[Cloned Templates](./VirtualInstance#using-premade-templates) to simplify the
code:

```lua
local function Button(props: {
    text: Dec.Observable<string>,
    position: UDim2,
    activated: () -> (),
})
    return Dec.Clone(game.ReplicatedStorage.UITemplates.Button, {
        Activated = props.activated,
        Text = props.text,
        Position = props.position,
    })
end
```

Finally, we can achieve the same result as our original example by passing in
the right props:

```lua
local function Gui()
    local buttonText = Dec.State("Click Me!")
    local button = Button({
        text = buttonText,
        position = UDim2.fromScale(0.5, 0.5),
        activated = function()
            buttonText:Set("Thanks :3")
        end,
    })
    return Dec.New("ScreenGui", {ResetOnSpawn = false}, {button})
end
root:Render(Gui())
```

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/ClickyButton2.gif" />
</center>

In Dec, the rule for best practices is this: **all Components should take in a
single Props table as an argument, and return a single VirtualInstance depending
on the value of these Props.**

----

## Re-Using Components

In the previous example, we saw a way of using props to aid in the _abstraction_
of a Dec component. Doing this also makes it easy to _re-use_ code for UI
components that appear to the user in multiple instances!

Let's refactor the code in the previous example to have the button component
show a secret message when clicked:

```lua
local function SpoilerButton(props: {
    previewText: string,
    secretText: string,
    position: UDim2,
})
    local secretIsShown = Dec.State(false)
    return Dec.Clone(game.ReplicatedStorage.UITemplates.SpoilerButton, {
        Activated = function()
            if secretIsShown:Current() then
                return
            end
            secretIsShown:Set(true)
            task.wait(2)
            secretIsShown:Set(false)
        end,
        Text = secretIsShown:Map(function(currentSecretIsShown)
            if currentSecretIsShown then
                return props.secretText
            else
                return props.previewText
            end
        end),
        Position = props.position,
    })
end
```

In the above example, the _props_ parameter was refactored to only take three
static values, then using [Observable Mapping](./State#mapping-observables) to
switch between showing the preview text and the secret text based on a single
boolean state of whether or not the secret should be shown.

The `SpoilerButton` component can now be re-used many times in the main Gui
component to show three different secrets:

```lua
local function OpinionBio()
    return Dec.New("ScreenGui", {ResetOnSpawn = false}, {
        Button1 = SpoilerButton({
            previewText = "Cats or Dogs?",
            secretText = "Dogs",
            position = UDim2.fromScale(0.5, 0.39),
        }),
        Button2 = SpoilerButton({
            previewText = "Flavor of Ice Cream?",
            secretText = "Strawberry",
            position = UDim2.fromScale(0.5, 0.5),
        }),
        Button3 = SpoilerButton({
            previewText = "Favorite Musician?",
            secretText = "Erykah Badu",
            position = UDim2.fromScale(0.5, 0.61),
        }),
    })
end
```

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/OpinionBio.gif" />
</center>