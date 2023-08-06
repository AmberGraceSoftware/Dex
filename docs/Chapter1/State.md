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
are being conveyed to the user. Here's a breakdown of what states some of these
UI components are using:

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

Beyond just generating UI, Dec is a library that makes it easy to translate
these state variables into the desired visuals for your project!

## `CoinCounter` Component

Let's turn the "coins" variable in our CoinCounter example into a State. We can
create a State that holds a number variable by calling the function
[Dec.State](/api/State):

```lua
local coins = Dec.State(0)
```

We can use `:Set()` to update this state and `:Current()` to get its current
value:

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
instance. Doing so will cause the UI to change to match the current value of the
State, and will automatically react to changes to this state's value!

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

***State*** actually inherits a base class called ***Observable***. Observables
are objects that  *hold some value* and can *listen to changes in this value*.

`Dec.State` is a special type of Observable in that its value can be *written
to;* however, some observables are "read-only" and their value depends on other
factors.

Let's pass "coins" as a paramater to the CoinCounter component. "coins" is both
a ***State*** object and an ***Observable*** object; however, since we only need
to read from this state within the `CoinCounter` component, we can type this
parameter as an ***Observable.***

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

The CoinCounter is now a fully *reactive* Component, as it generates visuals
based on the current value of an ***Observable*** object, and reactively updates
these visuals whenever that Observable's current value changes.

## Mapping Observables

Right now the `CoinCounter` component we created displays the raw value of
coins we have. But, let's say we wanted to add a "Pounds" symbol to the label
and two decimal points, so that `42` shows up as `£42.00`. To do this, we will
need to transform the coins state somehow.

***Mapping*** Is the process of transforming one observable to another by using
a mapping functions. Mapping is achieved in Dec by using
[Dec.Map](/api/Dec#Map), with the input observables as arguments. This function
returns another function which should be called with the ***Mapping Function***
as a first argument:

```lua
local coinsFormatted = Dec.Map(coins)(function(currentCoins)
    return string.format("£%.2f", currentCoins)
end)
```

The `coinsFormatted` object is an Observable object which updates its value
based on the current value of coins:

```lua
coins:Set(123)
print(coinsFormatted:Current()) -- £123.00
```

Mapping functions can take in multiple arguments. For example, if you wanted to
also store the currency as a state, you could map it like so:
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

We can also use [coins:Map()](/api/Observable#Map) as a shorthand for calling
`Dec.Map(coins)`; however, doing so will limit the mapping function to one
argument, and will discard the type information of the returned observable. It
is recommended to only use the `:Map()` method in cases like VirtualInstances
properties, where the value returned by `:Map()` is only used in one place and
never stored directly in a variable:

```lua
local function CoinCounter(coins: Dec.Observable<number>)
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = coins:Map(function(currentCoins)
                return string.format("£%.2f", currentCoins)
            end),
        })
    })
end
```

![Mapping In Use](/TutorialAssets/Chapter1/State/CoinsPoundsFormat.gif)

## Using Math Operations on Observables

Dec provides operator overloads for observables of the same number or vector
type! You can use operators like `+`, `-`, `*`, `/`, and `^` between two
observable objects to get a mapped observable:

```lua
local a = Dec.State(3)
local b = Dec.State(4)
local sum = a + b
print(sum:Current()) -- 7
a:Set(4)
print(sum:Current()) -- 8
```

In the above example, `sum` is equivalent to mapping `a` and `b` with an
summation mapping function:
```lua
local sum = Dec.Map(a, b)(function(currentA, currentB)
    return currentA + currentB
end)
```

## Subscribing to State

One nice thing about Observables in Dec is that they will always be garbage
collected (freed from memory) whenever they go *unused*. Observables are only
considered to be "used" if they are used by an active VirtualInstance, or if
they are ***Subscribed***

Subscribing to an observable lets you listen to changes in the value. For
example, if you wanted to print every time a certain value changes, you could do
so by calling `value:Subscribe()`, which in turn returns an `unsubscribe`
function

```lua
local value = Dec.State(42)
local unsubscribe = value:Subscribe(function(currentValue)
    print("The current value is ", currentValue)
end)
value:Set(128) -- The current value is 128
```

:::warning
If you directly Subscribe to Observables, **make sure to always handle the
returned unsubscribe function** when the observable is no longer needed. More
complex observables may stick around in memory until they are unsubscribed!
:::

### A Safer Alternative to `:Subscribe()`

A safe alternative to calling `Observable:Subscribe()` is the function
`Observable:SubscribeWhileMounted()`, which takes in a VirtualInstance as a
first parameter, and automatically unsubscribes to the observable's value once
the VirtualInstance is `unmounted` (i.e. is no longer being rendered by dec).

This is useful for components that have side effects on an input observable,
such as printing:

```lua
local function ComponentWithSideEffects(value: Dec.Observable<number>)
    local frame = Dec.Premade("Frame")

    -- This will keep printing until ComponentWithSideEffects is no longer
    -- rendered.
    value:SubscribeWhileMounted(frame, function(currentValue)
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