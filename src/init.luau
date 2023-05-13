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

export type Unsubscribe = Types.Unsubscribe
export type Observable<T> = Types.Observable<T>
export type State<T> = Types.State<T>
export type Alpha = Types.Alpha
export type Stopwatch = Types.Stopwatch
export type Timer = Types.Timer
export type CanBeObservable<T> = Types.CanBeObservable<T>
export type VirtualInstance = Types.VirtualInstance
export type Reconciled = Types.Reconciled
export type Symbol = Types.Symbol

local Dec = {}

return Dec