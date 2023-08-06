# Proposal: Dec.Clock observable subclass

This is a proposal to add an observable subclass, `Dec.Clock`, which tracks
the current result of `os.time()` and updates every second exactly when
`os.time()`'s return value updates

# Status: Unimplemented

## Use Cases:

This has many use cases in live events, countdown timers, and other widgets
which need to update their value exactly once per second.

## Example:

```lua
local function CountdownTimer()
    return Dec.Premade("TextLabel", {
        Text = Dec.Clock():Map(function(currentTimeUTC)
            local remaining = endTimeUTC - currentTimeUTC

            if remaining <= 0 then
                return "Event Has Ended!"
            end

            return string.format(
                "%d Seconds Remaining . . .",
                remaining
            )
        end)
    })
end
```

`Dec.Clock()` can just return a frozen singleton object, as subscribing to
real-time clock updates only needs to happen once in a whole application, and
clocks will always output the same value no matter what.

Dec's update stream system also means that `Dec.Clock()` will only bind to
render step / heartbeat exactly when and if it's necessary to do so in any
visible UI.