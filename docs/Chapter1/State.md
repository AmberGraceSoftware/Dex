---
sidebar_position: 5
---

# Creating & Mapping State

At its heart, Dec is also a language for representing ***State***. State is any
hidden variable that, when changed, will eventually lead to something updating
in a User Interface. State can be things like coins, whether or not a player is
hovering/pressing over a UI component, the price/display name/thumbnail of an
item being sold to the user, and more. Creating reactive UI Components in Dec
requires breaking down what simple variables are being displayed to the user
on-screen.

In the last section, we showed an example of a shop menu which appears when a
player interacts with an NPC:

![NPC Shop](/TutorialAssets/Chapter1/VirtualInstance/GecsSeafaringSupplies.jpg)

We can break this UI down into *States* by thinking about what hidden variables
are being conveyed to the user. Here's a breakdown of what variables some of
these UI components are using:

### `ShopHeader`:
```lua
local title: string -- The display name of the NPC's shop
```

### `CoinCounter`:
```lua
local coins: number -- How many coins the player currently has
```

### `ShopItem`:
```lua
local id: string -- What's the ID of the item we're showing?
local thumbnail: string -- What's the ID of the image thumbnail we're showing?
local displayName: string -- e.g. "Flintlock", "Sword"
local price: number -- How many coins does this cost?
```

Let's focus in on the `CoinCounter` Component that was covered in the last
section, and let's represent this "coins" variable as a state.

## `CoinCounter` Component

We can create a State that holds a number representing the player's coins by
calling the function [Dec.State](/api/State):

```lua
local coins = Dec.State(0)
```

Then, we can use `:Set()` to update this state and `:Current()` to get its
current value:

```lua
print(coins:Current()) -- 0
coins:Set(42)
print(coins:Current()) -- 42
```

Let's now utilize this state in our UI.

So far, we've seen examples of using ***VirtualInstances*** to assign static
properties of an instance:
```lua
local coinsLabel = Dec.Premade("TextLabel", {
    Text = "42",
})
```

Dec also supports passing in *States* to the property table of a virtual
instance. Doing so will cause the UI to automatically update whenever this
state changes!

```lua
local coinsLabel = Dec.Premade("TextLabel", {
    Text = coins,
})
```

![Reactive Coins UI](/TutorialAssets/Chapter1/State/CoinsReactive.gif)

The way in which Dec Components generate visuals from State follows a software
paradigm called [*Reactive Programming*](https://en.wikipedia.org/wiki/Reactive_programming).
To gain a better understanding of how Reactive Programming works in Dec, let's
quickly go over a core concept in Dec: ***Observables***

## Observables

***State*** actually [*inherits*](https://en.wikipedia.org/wiki/Inheritance_(object-oriented_programming))
from a base class called ***Observable***. Observables are objects that  *hold
some value* and can *listen to changes in this value*.

`Dec.State` is a special type of Observable in that its value can be *written
to;* however, some observables are "read-only" and their value depends on other
factors.

Let's pass "coins" as a paramater to the CoinCounter component. "coins" is both
a ***State*** object and an ***Observable*** object; however, since we only need
to read from this state within the `CoinCounter` component, we can type this
parameter as an ***Observable*** to make the component more re-usable.

```lua
local function CoinCounter(coins: Dec.Observable<number>)
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = coins,
        })
    })
end
```

If we now render this component in our application, we can write some code that
1) Creates a Coins state; 2) Creates a CoinCounter that reactively renders this
state; and 3) updates this state over time.

```lua
-- Create a state to hold coins
local coins = Dec.State(0)

-- Render a new CoinCounter component within a Dec.Root object (presumed to
-- exist in this scope)
root:Render(CoinCounter(coins))

-- Increment the value of coins every second
while task.wait(1) do
    coins:Set(coins:Current() + 1)
end
```

![Reactive Coins UI](/TutorialAssets/Chapter1/State/CoinsCountToTen.gif)

The `CoinCounter` is now a fully *reactive* Component, as it generates visuals
based on the value of an ***Observable***, and updates these visuals whenever
the Observable's value changes!

## Mapping Observables

Right now the `CoinCounter` component we created displays the raw value of
coins we have. But, let's say we wanted to add a "Pounds" symbol to the label
and two decimal points, so that `42` shows up as `£42.00`. To do this, we will
need to transform the coins state somehow.

***Mapping*** Is the process of transforming one observable to another by using
a transformation function. Mapping is achieved in Dec by calling
[Dec.Map](/api/Dec#Map) with the state we want to map, then calling the returned
value again with a transformation function.

The ***Mapping*** syntax looks like this:

```lua
local coinsFormatted = Dec.Map(coins)(function(currentCoins)
    return string.format("£%.2f", currentCoins)
end)
```

Here we created a an ***Observable string***, whose value depends on the
current value of coins (an observable number). Updating the `coins` state will
also update the value of `coinsFormatted`:

```lua
coins:Set(123)
print(coinsFormatted:Current()) -- £123.00
```

Let's use a mapped value to format the `coins` observable in our `CoinCounter`
component example:
```lua
local function CoinCounter(coins: Dec.Observable<number>)
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = Dec.Map(coins)(function(currentCoins)
                return string.format("£%.2f", currentCoins)
            end),
        })
    })
end
```

![Mapping In Use](/TutorialAssets/Chapter1/State/CoinsPoundsFormat.gif)

## Mapping Multiple Values

***Observable Mapping*** can take in multiple inputs. For example, if you wanted
to derive a value from `coins` and a `currency` type, you would simply call
`Dec.Map` with two arguments:

```lua
local coins = Dec.State(0)
local currency = Dec.State("£")
local coinsFormatted = Dec.Map(currency, coins)(function(
    currentCurrency,
    currentCoins
)
    return string.format("%s%.2f", currentCurrency, currentCoins)
end)
print(coinsFormatted:Current()) -- £0.00

coins:Set(42)
currency:Set("$")
print(coinsFormatted:Current()) -- $42.00
```

:::info
Dec provides a shorthand method for mapping an single input observable to a
single output observable called [:Map()](/api/Observable#Map). Due to a current
Luau language limitation, calling the `:Map()` method will discard the type
information of the output observable, so you should prefer using `Dec.Map`
over `Observable:Map()` in most cases for the sake of type safety.

`:Map()` is still useful in situations where you do not need the type of the
output observable, such as when storing it as a VirtualInstance property:
```lua
return Dec.Premade("TextLabel", {
    Text = coins:Map(function(currentCoins)
        return string.format("£%.2f", currentCoins)
    end),
})
```
:::

## Using Math Operations on Observables

:::caution
This feature has been disabled due to a regression in Luau's type system.
:::

~~Dec provides operator overloads for observables of the same number or vector
type! You can use operators like `+`, `-`, `*`, `/`, and `^` between two
observable objects to get a mapped observable:~~

```lua
local a = Dec.State(3)
local b = Dec.State(4)
local sum = a + b
print(sum:Current()) -- 7
a:Set(4)
print(sum:Current()) -- 8
```

~~In the example above, `sum` is equivalent to mapping `a` and `b` with an
summation mapping function:~~
```lua
local sum = Dec.Map(a, b)(function(currentA, currentB)
    return currentA + currentB
end)
```

~~You can also use math overloads on an Observable and its same value type. For
example, you can add a UDim2 with an *Observable UDim2*:~~

```lua
local basePosition: Dec.Observable<UDim2> = Dec.State(UDim2.fromScale(0.5, 0.1))
local PADDING = UDim2.fromScale(0.05, 0.05)
local paddedPosition = basePosition + PADDING
print(paddedPosition:Current()) -- ~ {0.55, 0}, {0.15, 0}
```

## Subscribing to State

The primary feature of Observables is, of course, that they can be *observed*.
This is done by calling the `:Subscribe()` method, which calls a listener
whenever the observable's value changes, and can be unsubscribed.

```lua
local value = Dec.State(42)
local unsubscribe = value:Subscribe(function(currentValue)
    print("The current value is ", currentValue)
end)
value:Set(128) -- The current value is 128
value:Set(256) -- The current value is 256
```

:::danger
If you directly Subscribe to Observables, **make sure to always handle the
returned unsubscribe function** when the observable is no longer needed. More
complex observables may stick around in memory until they are unsubscribed!
:::

Observables have one caveat that they *might* stick around in memory as long as
there is a listener subscribing to them. This is because, as we will cover in
later sections, some observables like *Stopwatches*, *Springs*, etc. need to
bind to Heartbeat to update their value every frame. Subscribing to an
Observable for the first time may *set up* side effects that will only be taken
down once the Observable is *unsubscribed* by all listeners.

### A Safer Alternative to `:Subscribe()`

A safe alternative to calling `Observable:Subscribe()` is the function
`VirtualInstance:SubscribeWhileMounted()`, which takes in the Observable as a
first parameter, and automatically unsubscribes to the observable's value once
the VirtualInstance is ***Unmounted*** (i.e. is no longer being rendered by
Dec).

We can use this inside a component to safely handle side effects and debugging
in a way that cleans itself up when the Component's Virtual Instances stop being
rendered by Dec:

```lua
local function ComponentWithSideEffects(value: Dec.Observable<number>)
    local frame = Dec.Premade("Frame")

    -- This will keep printing changes to the value until the frame is no longer
    -- rendered
    frame:SubscribeWhileMounted(value, function(currentValue)
        print("The current value is", currentValue)
    end)

    return frame
end
```

The above code sample will keep printing the value passed in until we call
`root:Destroy()` on our [Root](/api/Root) component, or unmount the
VirtualInstance returned by ComponentWithSideEffects some other way.

In a later section, we will go over ways in which virtual instances can be
mounted/unmounted automatically based on application state.