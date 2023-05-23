--!strict
local Types = require(script.Parent.Parent.Types)
local Observable = require(script.Parent.Observable)

export type TweenState = Types.TweenState

local TweenState = {}
TweenState.__index = {}
TweenState.__index._dectype = "Observable"
TweenState.__index._decobservabletype = "TweenState"

--[[
    @return void

    Start the tween. VirtualInstance that have added this observable as a
    Tween State (via virtualInstance:Tweens({myTweenState})) will start playing
    the tween.
]]
function TweenState.__index.Play(self: TweenState): ()
    error("Not implemented yet")
end

--[[
    @return void

    Cancel the ongoing tween.
]]
function TweenState.__index.Cancel(self: TweenState): ()
    error("Not implemented yet")
end

--[[
    @param goalProps: table - The desired final property values of the tweened Instance.
    @return void

    Sets the goal properties of the tween.
]]
function TweenState.__index.SetGoal(
    self: TweenState,
    goalProps: {[string]: any}
): ()
    error("Not implemented yet")
end

--[[
    @param info: TweenInfo? - The TweenInfo of the Tween.
    @return void

    Sets the TweenInfo of the Tween.
]]
function TweenState.__index.SetInfo(
    self: TweenState,
    info: TweenInfo
): ()
    error("Not implemented yet")
end

--[[
    @param startProps: {[string]: any}? - The starting property values of the tweened Instance.
    @return void

    Sets the start properties of the tween. If nil, the tween will not reset
    the properties of any tweened Instances before playing. If non-nil, the
    tween will reset the properties of any tweened Instances before playing.
]]
function TweenState.__index.SetStart(
    self: TweenState,
    startProps: {[string]: any}?
): ()
    error("Not implemented yet")
end

--[[
    @param cb: function - The function to be called when the tween completes.

    @return void

    Sets the function to be called when the tween completes.
]]
function TweenState.__index.SetOnCompleted(
    self: TweenState,
    cb: (() -> ())?
): ()
    error("Not implemented yet")
end

TweenState.__index.Current = Observable.__index.Current
TweenState.__index.Subscribe = Observable.__index.Subscribe
TweenState.__index.Destroy = Observable.__index.Destroy

--[[
    @param info: TweenInfo - The TweenInfo of the Tween.
    @param startProps: table - The starting property values of the tweened Instance.
    @param goalProps: table - The desired final property values of the tweened Instance.
    @param completed: function - The function to be called when the tween completes.

    @return Dec.TweenState - The new TweenState Observable.

    Creates a new TweenState Observable with the provided TweenInfo, start
    properties, goal properties and completion callback.
]]
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
