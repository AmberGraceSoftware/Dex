---
sidebar_position: 5
---

# Creating & Mapping State

:::warning
Tutorials are still in progress, and will be released section-by-section
:::

## Using State in your Components

At its heart, Dec is also a language for representing ***State***, and having
instances reactively change their properties based on changes in state. States
are any variables underlying what's being rendered. Writing effective Dec
applications also requires down what *States* each component is rendering:

(image of state breakdown)

In the previous section, we created a CoinCounter UI using a premade template.
In this example, the only state that CoinCounter needs to render is a number
representing how many coins a player has. We can create this state using
`Dec.State`, passing in an initial value for the coins as a first argument:

```lua
local coins = Dec.State(0)
```

Dec States can be updated using `Set()`, and their current value can be
retreived using `Current()`:
```lua
print(coins:Current()) -- 0
coins:Set(42)
print(coins:Current()) -- 42
```

So far, we've seen VirtualInstances defining the static properties of an
instance to be renderered — however, we can also have these properties change
*reactively* to state
```lua
local coinsLabel = Dec.Premade("TextLabel", {
    Text = coins,
})
```

(Image of coin counter showing 42 coins)

## Observables

States are actually a type of ***Observable***. Observables are objects that,
generally speaking, *hold some value* and can *listen to changes in this value*.
`Dec.State` is a special type of Observable in that its value can be written
to; however, many times, we only need to read the value of an Observable rather
than writing to it.

Observables can be passed as ***Props*** to a Component. Props is essentially
a table of named parameters to a Dec component which affects the final
output of the component:

```lua
local function CoinCounter(props: {
    coins: Dec.Observable<number>
})
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = props.coins,
        })
    })
end
```

In this example, we can use the CoinCounter to modify a premade asset by
updating the text label "CoinsLabel" to match the value of an observable state
we pass in:

```lua
-- CoinCounter will start rendering "0"
local coins = Dec.State(0)
local CoinCounter = CoinCounter({
    coins = coins,
})

task.wait(3)

coins:Set(42) -- CoinCounter will now render with "42" after 3 seconds
```

(video of animation changing the coins display from 0 to 42 in realtime after 3
seconds)

## Mapping Observables

Right now the `CoinCounter` component we created displays the raw value of
coins we have. But, let's say we wanted to add a "Pounds" symbol to the label
and two decimal points, so that `42` shows up as `£42.00`. To do this, we will
need to transform the coins state somehow.

***Mapping*** Is the process of transforming one observable to another by using
a mapping functions. Mapping is achieved in Dec by using `Dec.Map`, with the
input observables as arguments. This function returns another function
which should be called with the ***Mapping Function*** as a first argument:

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

We can also use `coins:Map()` as a shorthand—however, doing so will limit the
mapping function to one argument, and will discard the type information of the
returned observable. It's recommended to only call the `:Map()` in cases
like VirtualInstances properties, the value returned by `:Map()` is only used
in one place and never stored directly in a variable:

```lua
local function CoinCounter(props: {
    coins: Dec.Observable<number>
})
    return Dec.Premade("Frame", {}, {
        CoinsLabel = Dec.Premade("TextLabel", {
            Text = props.coins:Map(function(currentCoins)
                return string.format("£%.2f", currentCoins)
            end),
        })
    })
end
```

(Image of formatted CoinCounter UI)

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
local function ComponentWithSideEffects(props: {
    value: Dec.Observable<number>
})
    local frame = Dec.Premade("Frame")

    -- This will keep printing until ComponentWithSideEffects is no longer
    -- rendered.
    props.value:SubscribeWhileMounted(frame, function(currentValue)
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