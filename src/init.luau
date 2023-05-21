--!strict
--[[
    Dec is a reactive UI library for Roblox.

    Dec combines all of the best features of modern libraries like Roact,
    Fusion, and more for building reusable, performant, declarative UI
    components.

    Github Repository: AmberGraceSoftware/Dec
    Wally Package ID: ambergracesoftware/dec
    Documentation: Found on Github
]]

local Types = require(script.Types)
local Symbols = require(script.Symbols)

export type Unsubscribe = Types.Unsubscribe
export type Observable<T> = Types.Observable<T>
export type State<T> = Types.State<T>
export type Alpha = Types.Alpha
export type Stopwatch = Types.Stopwatch
export type Timer = Types.Timer
export type CanBeObservable<T> = Types.CanBeObservable<T>
export type VirtualInstance = Types.VirtualInstance
export type ReconciledNode = Types.ReconciledNode
export type Root = Types.Root
export type Symbol<Name> = Types.Symbol<Name>
export type Nil = Symbol<"Nil">

local Dec = {}

Dec.Nil = Symbols.Nil

return Dec