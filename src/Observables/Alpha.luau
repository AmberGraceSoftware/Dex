--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type Alpha = Types.Alpha

local Alpha = {}
Alpha.__index = {}
Alpha.__index._dectype = "Observable"
Alpha.__index._decobservabletype = "Alpha"

function Alpha.__index.Slice(
    self: Alpha,
    startAlpha: number,
    endAlpha: number
): Alpha
    error("Not implemented yet")
end

function Alpha.__index.Interpolate(
    self: Alpha,
    easingStyle: Enum.EasingStyle?,
    easingDirection: Enum.EasingDirection?
): Alpha
    error("Not implemented yet")
end

Alpha.__index.Current = Observable.__index.Current
Alpha.__index.Subscribe = Observable.__index.Subscribe
Alpha.__index.Destroy = Observable.__index.Destroy

function Alpha.new(initialValue: number): Alpha
    return setmetatable({
        _current = initialValue,
        -- _consumers = nil,
        -- _consumersWeak = nil,
    }, Alpha :: any)
end

return Alpha
