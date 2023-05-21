--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type TweenState = Types.TweenState

local TweenState = {}
TweenState.__index = {}
TweenState.__index._dectype = "Observable"
TweenState.__index._decobservabletype = "TweenState"

function TweenState.__index.Start(self: TweenState): ()
    error("Not implemented yet")
end

function TweenState.__index.Cancel(self: TweenState): ()
    error("Not implemented yet")
end

function TweenState.__index.SetGoal(
    self: TweenState,
    goalProps: {[string]: any}
): ()
    error("Not implemented yet")
end

function TweenState.__index.SetInfo(
    self: TweenState,
    info: TweenInfo
): ()
    error("Not implemented yet")
end

function TweenState.__index.SetStart(
    self: TweenState,
    startProps: {[string]: any}?
): ()
    error("Not implemented yet")
end

function TweenState.__index.SetOnCompleted(
    self: TweenState,
    cb: (() -> ())?
): ()
    error("Not implemented yet")
end

TweenState.__index.Current = Observable.__index.Current
TweenState.__index.Subscribe = Observable.__index.Subscribe
TweenState.__index.Destroy = Observable.__index.Destroy

function TweenState.new(
    info: TweenInfo,
    startProps: {[string]: any}?,
    goalProps: {[string]: any},
    completed: (() -> ())?
): TweenState
    return setmetatable({
        _current = {
            info = info,
            startProps = startProps,
            goalProps = goalProps,
            completed = completed,
        },
        _currentTween = nil,
        -- _consumers = nil,
        -- _consumersWeak = nil,
    }, TweenState :: any)
end

return TweenState
