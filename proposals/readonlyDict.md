## Proposal: Readonly Dict/Record types

This is a proposal to add type-casting overloads to the `Dec.Dict` and
`Dec.Record` constructor functions, which can cast an existing observable state
to a Record/Dict type, allowing indexing an arbitrary state, so long as its base
type is a table.

## Status: Unimplemented

## Use Cases:

`Record:Index` and `Dict:Index` are very powerful methods, as they reduce the
time complexity of state updates that may happen in UI code from O(N) to O(1)
for free.

A very common use case for this would be something like an infinite-scroll shop
component, which contains many different cards. Sometimes state is held
monolithically, and needs to be distilled to a number of smaller states, but
doing so is difficult if `Dict` and `Record` is unable to be directly used.

This proposal adds an overload to `Dec.Dict()` and `Dec.Record` that wraps/
essentially typecasts an existing Observable object to a Dict/Record, provided
the root observable's type is a table.

## Examples

One way this can be used is indexing parts of a state passed in props.
```lua
function Component(props: {
    info: Dec.Observable<{
        id: string,
        displayName: string,
        description: string,
    }>
})
    -- Cast as Dec.ReadOnlyRecord to allow indexing
    local info = Dec.Record(valueFromProps)

    return Dec.Premade("Frame", {}, {
        Title = Dec.Premade("TextLabel", {
            Text = info:Index("displayName"),
        }),
        Body = Dec.Premade("TextLabel", {
            Text = info:Index("description"),
        })
    })
end
```

Here, using `info:Index()`` simplifies a more complex 3-line expression:
```lua
Text = info:Map(function(currentInfo)
    return info.displayName,
end)
```