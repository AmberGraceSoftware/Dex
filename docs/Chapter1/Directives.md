---
sidebar_position: 9
---

# VirtualInstance Directives

Dec tries to allow access to all use cases in Roblox's [Data Model](https://create.roblox.com/docs/projects/data-model) through VirtualInstances.

VirtualInstances aim to be as declarative as possible (i.e. described in
terms of _how they are put together in relation to state_ rather than in terms
of the exact instructions for how to put them together). Dec uses a concept
called ***Directives*** to bridge this gap.

Directives are declarations that can always be _added_ to a VirtualInstance, but
never removed. Once a VirtualInstance is rendered by Dec, it becomes
***frozen***, meaning the VirtualInstance cannot have anymore directives added
onto it.

## Basic Directives

The [:SetProperties()](/API/VirtualInstance#SetProperties) and
[:AddChildren()](/API/VirtualInstance#AddChildren) methods on the
VirtualInstance add directives to assign a VirtualInstance's properties, and add
children respectively. Dec also provides syntax sugar for defining them in the
arguments to VirtualInstance constructors like [Dec.New](/api/Dec#New)
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

The previous section also goes over the [`:MapChildren()`,
`:MapChildrenByKey()`, and
`:MapChildrenByValue()` directives](./MappingChildComponents), which are more
optimized ways of specifying the children of a VirtualInstance.

Let's go over a few more directives and how they work.


## Defining Attributes

Dec can render attributes in a similar way to properties by adding a
`:SetAttributes()` directive. This takes in a table that can contain static
or observable values:

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
[CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService)
to a VirtualInstance while it is rendered.

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
<center>
    <img width="80%" src="/TutorialAssets/Chapter1/Directives/RenderedTags.png" />
</center>

CollectionService tags can be useful when interfacing with non-Dec code which
may already exist in a project's codebase, and are helpful for applying global
effects like pixel-sized UI elements based on the screen resolution.

## Connecting Events

Providing a function value in the `:SetProperties()` directive will connect a
listener on a VirtualInstance as long as it is rendered, automatically
disconnecting the event listener when no longer needed:
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

## Listening to Property/Attribute change events

Dec provides the directives
[:OutProperty()](https://dec.ambergracesoftware.com/api/VirtualInstance#OutProperty)
and [:OutAttribute()](https://dec.ambergracesoftware.com/api/VirtualInstance#OutProperty)
to listen to changes in a specific property or attribute while the
VirtualInstance is being rendered by Dec. These directives return an Observable
object which changes when the property or attribute changes, and are initialized
to the second value passed in as an argument to the directive:

```lua
local function LabelComponent(props: {
    text: Dec.Observable<string>m
})
    local label = Dec.Premade("TextLabel", {
        Text = props.text,
    })
    -- Create an Observable which tracks the ContentText (translated text) of
    -- the label in realtime. This observable initializes to an empty string
    -- (second argument) until label is mounted.
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

When working on premade VirtualInstance trees, you may commonly need to define
a child VirtualInstance, then set it as a child of another VirtualInstance:

```lua
local child = Dec.Premade("Frame")
parentVirtualInstance:AddChild("ChildName", child)
```

The `:FindChild()` directive conveniently simplifies this idiom into just one
statement:
```lua
local child = parentVirtualInstance:FindChild("ChildName")
```

## Combining VirtualInstances

Dec provides a special directive, [:Combine](/api/VirtualInstance#Combine),
which allows one or more Premade-type VirtualInstances to be combined with
another VirtualInstance as a way of composing the behavior of multiple
components:

The VirtualInstances passed to the `:Combine()` directive must meet the
following requirements:

- They must be of "Premade" type, with an equivalent or related ClassName to the
target VirtualInstance.
- They must not already be rendered by Dec and/or combined with another
VirtualInstance.

```lua
local function PrintOnPress()
    return Dec.Premade("GuiButton", {
        Activated = function()
            print("Button was pressed!")
        end,
    })
end
```
Example of combining this component with another component:
```lua
local function Button()
    local button = Dec.Premade("TextButton", {
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