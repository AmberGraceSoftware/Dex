# API Propposal: Timed sequences

# Status: Unimplemented

This is pretty important for a number of use cases. I figure, since Dec already 
contains a number of utility subclasses for observable, having one for sequences
would be immeasurably useful, provided the API is easy to get a hang of.

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