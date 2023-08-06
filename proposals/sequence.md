# Proposal: Timed sequences

This is a proposal to add a observable subclass, created via `Dec.Sequence`,
which is an object that holds state about a timed sequence.

# Status: Unimplemented

## Use Case:

Sequences are pretty important for a number of use cases involving animations
that have multiple steps.

I figure, since Dec already contains a number of utility subclasses for
observables involving animations/timing, having one for discretely-steped
sequences would be immeasurably useful, provided the API is easy to get a hang
of.

## Example:

```lua
--!nocheck
local Dec: any = nil

local sequence = Dec.Sequence({
    {
        stepName = "fadeIn",
        duration = 3
    }, {
        stepName = "sparkle",
        duration = 0.5,
    }, {
        stepName = "show",
        duration = 2
    }, {
        stepName = "fadeOut",
        duration = 3
    }
})

local graphemesPerSecond = 40
sequence:AlphaForStep("fadeIn")
sequence:ElapsedForStep("sparkle"):Map(function(currentTime)
    return currentTime * graphemesPerSecond
end)

sequence:Start()
sequence:Pause()
sequence:Stop()
sequence:SetTimePosition(6)

local fadeIn = sequence:AddStep(3)
local sparkle = sequence:AddStep(0.5)
local show = sequence:AddStep(2)
local fadeOut = sequence:AddStep(3)
```