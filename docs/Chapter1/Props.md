---
sidebar_position: 7
---

# Structure of a Component

The previous two sections covered the fundamentals of
[Virtual Instances](./VirtualInstance) and [State](./State), and how to use them
to write UI components.

This section will go over some ideas on how to _scale up_ many components in an
application to meet a project's needs, and some conventions / best practices for
doing so.

## Using _Props_ in Dec

_Props_ is a concept borrowed primarily from the JavaScript framework
[React](https://react.dev/learn/passing-props-to-a-component) as a way for
standardizing the parameters of a Dec Component. In Dec, you can define your
Component with as many arguments as you want, but it is recommended you use a
single table parameter called _props_:

```lua
local function Component(props)
    -- Extract different named parameters from the props table.
    local text = props.text
    local position = props.position

    -- Return a VirtualInstance based on the values in the props table
    return Dec.New( . . . )
end
```

This mirrors the way ***Virtual Instance*** are defined, where `Dec.New` accepts
a properties table, which can take in both static values and states to define
how the object is put together:

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

The example above shows [Dec.New](/api/Dec#New) taking in three different types
of properties:

- **Static Values** (e.g. `number`, `UDim2`, `Vector2`, and `Color3` values)
- **States** (e.g. `buttonText`)
- **Callbacks** (e.g. connecting to the "Activated" event)

In much the same way that Dec allows you to define a VirtualInstance using a
table of _properties_, you can pass these same three types of arguments to a Dec
Component via _props_.

Let's add a _props_ parameter to the `Button` component, allowing for `Button`
components to be instantiated multiple times in the UI. To do this, let's first
lay out some design requirements:

- Each button should have a different _position_
- Each button should have a different _text_ value, which can _change over time_
- Each button should _do something different_ when clicked.

With these requirements in mind, let's write out the type for a _props_ table:

```lua
local function Button(props: {
    position: UDim2,
    text: Dec.Observable<string>,
    activated: () -> (),
})
```

Here, we defined the structure of our props table using a _type annotation_. Dec
makes use of [Luau's Static Type System](https://luau-lang.org/typecheck), and
it is recommended to give type annotations to the parameters of Dec Components,
with `--!strict` mode enabled where possible.

The type annotation in the example above defines the following values in
`props`:
- `position`: A ***static UDim2 value***, representing where the button should
be positioned.
- `text`: An ***Observable string*** representing the current text to
display in the button, which may change over time.
- `activated`: A ***callback function*** which is called whenever the button is
clicked. It takes in no arguments and returns no values.

The original component can now be refactored to utilize the three values we
defined in props, as well as utilizing a
[Cloned Templates](./VirtualInstance#using-premade-templates) to simplify the
code:

```lua
local function Button(props: {
    position: UDim2,
    text: Dec.Observable<string>,
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

In Dec, the best practice for writing components is this: **Components should
take in a single Props table as a parameter, and return a single VirtualInstance
depending on the value of these Props.**

## Re-Using Components

In the previous example, we saw a way of using props to aid in the _abstraction_
of a UI component. Doing this also makes it easy to _re-use_ code for UI
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

In the example above, the _props_ parameter was refactored to only take three
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

With [Premade Templates](./VirtualInstance#using-premade-templates) we can also
adjust things like font, color, and padding in the UI without changing any of
the code itself:

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/OpinionBio.gif" />
</center>



## _Optionally Observable_ Props

Previously, we saw cases where _static values_ and _Observable values_ can be
passed as an argument to a UI Component. However, there may be cases where both
might be supported.

In the `SpoilerButton` example, `previewText` and `secretText` must remain the
same over time. But what if you wanted to make it possible for `secretText` to
change over time?

Dec provides a utility type [CanBeObservable](/api/Dec#CanBeObservable), which
allows for something to be a static value _or_ an Observable value in props!
For any value type `T`, `CanBeObservable<T>` is just shorthand for the union
type `T | CanBeObservable<T>`

```lua
local function SpoilerButton(props: {
    previewText: Dec.CanBeObservable<string>,
    secretText: Dec.CanBeObservable<string>,
    position: UDim2,
})
```

When a prop has this type, you can pass in both states and static values as an
argument to the Component:

```lua
local secret = Dec.State(tostring(math.random(1, 1000)))
task.spawn(function()
    while task.wait(4) do
        secret:Set(tostring(math.random(1, 1000)))
    end
end)

local button = SpoilerButton({
    previewText = "Reveal Secret Number",
    secretText = secret,
    position = UDim2.fromScale(0.5, 0.5)
})
```

In the example above, we passed a ***static string*** to `previewText` and an
***Observable String*** to `secretText` which changes its value every 4 seconds.

In order to parse this in our component, we will need to use the helper function
provided by Dec: [CoerceAsObservable](/api/Dec#CoerceAsObservable). This
function takes in an object that can be an observable (`CanBeObservable<T>`),
and returns an observable object (`Observable<T>`) of that same type!

Let's implement this in the `SpoilerButton` component:

```lua
local function SpoilerButton(props: {
    previewText: Dec.CanBeObservable<string>,
    secretText: Dec.CanBeObservable<string>,
    position: UDim2,
})
    -- Convert optionally observable props to Observable<string> objects
    local previewText = Dec.CoerceAsObservable(props.previewText)
    local secretText = Dec.CoerceAsObservable(props.secretText)

    -- Derive the final text output from all observable objects' current values
    local textOutput = Dec.Map(secretIsShown, previewText, secretText)(function(
        currentSecretIsShown,
        currentPreviewText,
        currentSecretText
    )
        if currentSecretIsShown then
            return currentSecretText
        else
            return currentPreviewText
        end
    end)

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
        Text = textOutput,
        Position = props.position,
    })
end
```

The `SpoilerButton` Component will now work the same as it did before in the
`OpinionBio` example, where `secretText` is a *static string* value, but will also
now work in the "Reveal Secret Number" example, where `secretText` is an
*Observable string*:

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/SecretNumber.gif" />
</center>