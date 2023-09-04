---
sidebar_position: 9
---

# VirtualInstance Directives

Dec tries to allow access to all use cases in Roblox's [Data Model](https://create.roblox.com/docs/projects/data-model) through VirtualInstances.

VirtualInstances aim to be as declarative as possible (i.e. described in
terms of _how they are put together in relation to state_ rather than in terms
of the exact instructions for how to put them together). Dec uses a concept
called ***Directives*** to bridge this gap.

***Directives*** are methods which declare special instructions on how to put
together an instance heirarchy based on application state. They can be _added_
to a VirtualInstance but _never removed._ Once a VirtualInstance is rendered by
Dec, it becomes ***frozen***, meaning no more directives can be added or removed
from the VirtualInstance.

## Basic Directives

The [:SetProperties()](/API/VirtualInstance#SetProperties) and
[:AddChildren()](/API/VirtualInstance#AddChildren) directives define a
VirtualInstance's properties and children respectively. The first two arguments
of VirtualInstance constructors (such as [Dec.New](/api/Dec#New)) automatically
add a `:SetProperties()` and `:AddChildren()` directive when defined.
```lua
-- Creating a VirtualInstance with "Properties" and "Children" tables defined:
local virtualInstance1 = Dec.New("Frame", {
    BackgroundTransparency = 1
}, {
    Dec.New("TextLabel")
})

-- . . . Is equivalent to adding a "SetProperties" and "AddChildren" directive!
local virtualInstance2 = Dec.New("Frame")
virtualInstance2:SetProperties({
    BackgroundTransparency = 1,
})
virtualInstance2:AddChildren({
    Dec.New("TextLabel"),
})
```

You can add these directives multiple times to split up the logic of a UI
component:
```lua
local function Component(props: {
    layoutOrder: number,
    coins: Dec.Observable<number>,
})
    -- Layout
    local label = Dec.New("TextLabel", {
        LayoutOrder = props.layoutOrder
    })

    -- Coins display
    label:SetProperties({
        Text = props.coins:Map(function(currentCoins)
            return string.format("%.2f", currentCoins)
        end)
    })

    return label
end
```

The previous section also goes over the [`:MapChildren()`,
`:MapChildrenByKey()`, and
`:MapChildrenByValue()` directives](./MappingChildComponents), which are more
optimized ways of specifying the children of a VirtualInstance.

Let's go over a few more ***Directives*** and their use cases.

## Defining Attributes

Dec can render attributes in a similar way to properties by adding a
`:SetAttributes()` directive. This takes in a table that can hold both _Static_
and _Observable_ values:

```lua
local function FrameWithAttributes(props: {
    id: Dec.Observable<string>
})
    local frame = Dec.New("Frame")
    frame:SetAttributes({
        id = props.id,
    })
    return frame
end
```
When rendered, this component will generate a frame with attributes that adjusts
to be equal to a state passed in via props:
```lua
local frame = FrameWithAttributes({
    id = Dec.State("ValueFromProps")
})
```
<center>
    <img width="80%" src="/TutorialAssets/Chapter1/Directives/RenderedAttributes.png" />
</center>

## Defining Tags

Dec also provides an `:AddTags()` directives, which adds
[CollectionService Tags](https://create.roblox.com/docs/reference/engine/classes/CollectionService)
to a VirtualInstance while it is being rendered.

The tag list can be an observable, and can also contain a list of observable
string values:

```lua
local function TaggedUIScaleConstraint(props: {
    darkMode: Dec.Observable<boolean>
})
    local uiScale = Dec.New("UIScale")
    frame:AddTags(props.darkMode:Map(function(darkModeEnabled)
        if darkModeEnabled then
            return {"ApplyDarkMode", "AutoScaling"}
        else
            return {"AutoScaling"}
        end
    end))
    return uiScale
end
```
```lua
local uiScale = TaggedUIScaleConstraint({
    darkMode = Dec.State(false)
})
```
<center>
    <img width="80%" src="/TutorialAssets/Chapter1/Directives/RenderedTags.png" />
</center>

## Connecting Events

The `:SetProperties()` directive can connect to listeners by providing a
function as a value for an event name:
```lua
local function Button()
    return Dec.Premade("GuiButton", {
        Activated = function()
            print("Button was pressed!")
        end,
    })
end
```

Alternatively, Dec provides a separate directive `:Connect()` which achieves
the same result:
```lua
local function Button()
    local button = Dec.Premade("GuiButton")
    button:Connect("Activated", function()
        print("Button was pressed!")
    end)
    return button
end
```

Dec will automatically clean up the connection/disconnection of these event
listeners while a VirtualInstance is being rendered.

## Listening to Property & Attribute Changed events

The [:OutProperty()](https://dec.ambergracesoftware.com/api/VirtualInstance#OutProperty)
and [:OutAttribute()](https://dec.ambergracesoftware.com/api/VirtualInstance#OutProperty)
directives listen to changes in a specific property or attribute while the
VirtualInstance is being rendered. These directives return an Observable
object which changes when the property or attribute changes, and are initialized
to the value and type of the second argument passed into the directive:

```lua
local function LabelComponent(props: {
    text: Dec.Observable<string>m
})
    local label = Dec.Premade("TextLabel", {
        Text = props.text,
    })
    -- Create an Observable which tracks the ContentText (translated text) of
    -- the label in realtime. This observable initializes to an empty string
    -- (second argument) until label is mounted and a ContentText is defined.
    local contentText = label:OutProperty("Text", "")

    -- Print whenever the translated text changes
    label:SubscribeWhileMounted(contentText, function(currentContentText)
        print("Translated text is", currentContentText)
    end)
end
```

:::info
For more on output directives such as `:OutProperty()`, `:OutAttribute()`,
`:OutInitialProperty()`, `:OutInitialAttribute()`, and `:OutInstance()`, see
[the Advanced tutorial on using these directives](/docs/Chapter2/EventsOutputObservables)
:::

## FindChild Directive

When working with premade VirtualInstance templates, you may commonly need to
define a child VirtualInstance, then set it as a child of another
VirtualInstance:

```lua
local child = Dec.Premade("Frame")
parentVirtualInstance:AddChild("ChildName", child)
```

The `:FindChild()` directive conveniently simplifies this idiom into a single
statement:
```lua
local child = parentVirtualInstance:FindChild("ChildName")
```

## Combining VirtualInstances

Dec provides a special directive, [:Combine](/api/VirtualInstance#Combine),
which combines the directive of one or more premade VirtualInstances with
another VirtualInstance. The VirtualInstances passed to the `:Combine()`
directive must meet the following requirements:

- They must be of "Premade" type, with an equivalent or related ClassName to the
target VirtualInstance.
- They must not already be rendered by Dec and/or combined with another
VirtualInstance.

Example:
```lua
local function PrintOnPress()
    return Dec.Premade("GuiButton", {
        Activated = function()
            print("Button was pressed!")
        end,
    })
end
```
```lua
local function Button()
    local button = Dec.New("TextButton", {
        Text = "Click Me!",
    })
    button:Combine(PrintOnPress())
    return button
end
```

:::info
For more on using the `:Combine()` directive effectively, see
[the Advanced tutorial on using Combine](/docs/Chapter2/Combine)
:::

## Lifecycle Callbacks

A VirtualInstance is ***Mounted*** when it is first rendered by Dec (either
passed in as an argument to [Root:Render()](/api/Root#Render), or created as a
child of another VirtualInstance). When the VirtualInstance stops being
rendered, it is ***Unmounted***, meaning any created instances, side effects,
etc. are automatically cleaned up by Dec.

Dec provides the directives [:OnMount()](/api/VirtualInstance#OnMont) and
[:OnUnmount()](/api/VirtualInstance#OnUnmount) to listen to these events for
custom side effects.

Example:
```lua
local function Component()
    local frame = Dec.New("Frame")
    frame:OnMount(function()
        print("Frame was mounted!")
    end)
    frame:OnUnmount(function()
        print("Frame was unmounted!")
    end)
    return frame
end
```

:::info
## SubscribeOnMounted directive
Dec provides the directive [:SubscribeOnMounted()](/api/VirtualInstance#SubscribeWhileMounted)
to listen for changes to an Observable, and automatically clean up this listener
when a VirtualInstance is no longer being rendered by Dec.

Under the hood, [:SubscribeOnMounted()](/api/VirtualInstance#SubscribeWhileMounted) 
uses `:OnMount()` and `:OnUnmount()` to set up and take down the side effect of
subscribing to an observable:
```lua
local function SubscribeWhileMounted<T>(
    self: VirtualInstance,
    input: Observable<T>,
    listener: (T) -> (),
    immediatelyCallListener: boolean
)
    local unsubscribe: (() -> ())? = nil
    self:OnMount(function()
        unsubscribe = input:Subscribe(listener, immediatelyCallListener)
    end)
    self:OnUnmount(function()
        if unsubscribe then
            unsubscribe()
        end
    end)
end
```

For custom side effects, this same pattern can be used to set up and take down
these custom effects while a VirtualInstance is being rendered.
:::