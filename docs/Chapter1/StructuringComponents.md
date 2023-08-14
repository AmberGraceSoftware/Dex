---
sidebar_position: 7
---

# Structure of Dec Components

The previous two sections covers the fundamentals of
[Virtual Instances](./VirtualInstance) and [State](./State), and how to use them
to write UI components.

This section will go over some conventions and best practices for _structuring_
UI components in Dec components.

## Using _Props_ in Dec

In Dec, you can define a UI Component that takes in as many parameters as
needed:

```lua
local function Component(text: string, position: UDim2)
    return Dec.New("TextLabel", {
        Text = text,
        Position = position,
        -- . . .
    })
end
```

However, as more and more parameters are added to a UI component, it becomes
increasingly more confusing what each argument is responsible for, and what
order they should be passed in. Because of this, the convention for Dec
Components is to always pass a single _table_ argument to components called
"props":

```lua
local function Component(props)
    -- Extract different named parameters from the props table.
    local text = props.text
    local position = props.position

    return Dec.New("TextLabel", {
        Text = text,
        Position = position,
        -- . . .
    })
end
```

_Props_ is a concept borrowed from
[React](https://react.dev/learn/passing-props-to-a-component), and mirrors
the way new ***Virtual Instances*** are created:

```lua
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
    }
```

In this example, [Dec.New](/api/Dec#New) takes in three different types
of objects as "properties" which work together to make an interactive UI:

- **Static Values** (e.g. `number`, `UDim2`, `Vector2`, and `Color3`), which do
not change over time
- **Observable Values** (e.g. `buttonText`), which can change over time
- **Callbacks** (e.g. `Activated = function() ... end`), which connect to input
events

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/ClickyButton.gif" />
</center>

<br/>

Props can also mirror this structure. Let's add a _props_ parameter to the
`Button` component, allowing for `Button` components to be instantiated multiple
times in the UI. To do this, let's first lay out some design requirements:

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

Here, we defined the structure of the props table using a _type annotation_. Dec
makes use of [Luau's Static Type System](https://luau-lang.org/typecheck), and
it is recommended to give type annotations to the props table of Dec Components,
with `--!strict` mode enabled where possible.

The type annotation in the example above defines the following values in
`props`:
- `position`: A ***Static UDim2*** value, representing where to place the
button.
- `text`: An ***Observable string***, representing the text to display with the
button (which changes over time).
- `activated`: A ***Callback*** function, which is called when the button is
pressed.

We can now refactor the `Button` Component to utilize the three values we
defined in props, as well as utilize a
[Cloned Template](./VirtualInstance#using-premade-templates:~:text=Clone%20Virtual%20Instances%20are%20also%20created%20by%20Dec%2C%20but%20are%20created%20created%20by%20copying%20an%20existing%20template%2C%20passed%20in%20as%20the%20first%20argument%20to%20Dec.Clone())
to simplify the code:

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

<br/>

In Dec, the best practice for writing components is that **Components should
take in a single Props table as a parameter, and return a single VirtualInstance
depending on the value of these Props.**

## Re-Using Components

We just saw a way of using props to aid in the _abstraction_ of a UI component.
Doing this also makes it easy to _re-use_ code for UI components that appear to
the user in multiple instances!

Let's write a Dec Component that creates a button which reveals a secret message
when clicked:

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

Here, the _props_ parameter takes in three static values, then uses
[Observable Mapping](./State#mapping-observables) to switch between showing the
preview text and the secret text based on an internal `boolean` state.

We can now re-use the interactive `SpoilerButton` component multiple times in
our UI at once:

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

Since `SpoilerButton` uses a
[Premade Template](./VirtualInstance#using-premade-templates), we can also
adjust things like font, color, and padding in the UI without changing any of
the code itself:

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/OpinionBio.gif" />
</center>



## _Optionally Observable_ Props

Props can define _Static values_ or _Observable values_ depending on the needs
of a Component. However, there may be cases where you want to define a value
that can be either a Static value _or_ an Observable value

Dec provides a utility type [CanBeObservable](/api/Dec#CanBeObservable), which
allows for something to be a static value _or_ an Observable value in props.
For any value type `T`, `CanBeObservable<T>` is just shorthand for the
[union type](https://luau-lang.org/syntax#type-annotations:~:text=Additionally%2C%20the%20type,all%20possible%20types.)
`T | Observable<T>` (i.e. "A value of type `T` or of type `Observable<T>`")

In the `SpoilerButton` Component, we can use the `CanBeObservable` type to allow
both a Static `string` and an Observable `string` to be defined in props for
`previewText` and `secretText`:

```lua
local function SpoilerButton(props: {
    previewText: Dec.CanBeObservable<string>,
    secretText: Dec.CanBeObservable<string>,
    position: UDim2,
})
```

Now we can create a spoiler button with a _Static string_ for `previewText`,
and an _Observable string_ for `secretText`, which changes every 4 seconds:

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

In order to parse this in a Component, we will need to use a helper function
provided by Dec: [CoerceAsObservable](/api/Dec#CoerceAsObservable). This
function takes in an object that can be an observable (`CanBeObservable<T>`),
and returns an observable object (`Observable<T>`) of that same type.

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
now work in cases where `secretText` is an *Observable string*:

<center>
    <img width="85%" src="/TutorialAssets/Chapter1/Props/SecretNumber.gif" />
</center>

----

The conventions outlined in this section are helpful for writing reactive and
re-usable Dec Components.

The next section will cover one final aspect concept needed to scale up a Dec
user interface: dynamically Creating & Destroying UI Components based on state.