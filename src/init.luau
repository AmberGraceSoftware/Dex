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
local VirtualInstanceCreators = require(script.VirtualInstanceCreators)
local Root = require(script.Reconciler.Root)
local Observable = require(script.Observables.Observable)

export type Unsubscribe = Types.Unsubscribe
export type Observable<T> = Types.Observable<T>
export type State<T> = Types.State<T>
export type StateRecord<T> = Types.StateRecord<T>
export type Spring<T> = Types.Spring<T>
export type IntSpring<T> = Types.IntSpring<T>
export type EasedValue<T> = Types.EasedValue<T>
export type Alpha = Types.Alpha
export type BaseTimer = Types.BaseTimer
export type Stopwatch = Types.Stopwatch
export type Timer = Types.Timer
export type CanBeObservable<T> = Types.CanBeObservable<T>
export type ChildMap = Types.ChildMap
export type VirtualInstance = Types.VirtualInstance
export type ReconciledNode = Types.ReconciledNode
export type Symbol<Name> = Types.Symbol<Name>
export type Root = Types.Root
export type Nil = Symbol<"Nil">

local Dec = {}

-- Basic State and Observables
Dec.State = require(script.Observables.State)
Dec.Map = require(script.Util.MapObservable)
Dec.Alpha = require(script.Observables.Alpha)
Dec.CustomObservable = Observable.new

-- Realtime simulation observable utilities
Dec.Spring = require(script.Observables.Spring).new
Dec.IntSpring = require(script.Observables.IntSpring)
Dec.AngleSpring = require(script.Observables.AngleSpring)
Dec.Eased = require(script.Observables.Eased)
Dec.Stopwatch = require(script.Observables.Stopwatch)
Dec.Timer = require(script.Observables.Timer)

-- Interop functions
Dec.ObserveFusionState = require(script.Interop.ObserveFusionState)

-- VirtualInstance Creators
Dec.New = VirtualInstanceCreators.New
Dec.Clone = VirtualInstanceCreators.Clone
Dec.Premade = VirtualInstanceCreators.Premade

-- Root-Level Reconciler API
Dec.CreateRoot = Root.new

-- Symbols
Dec.Nil = Symbols.Nil

-- Reflection
Dec.CoerceAsObservable = require(script.Util.CoerceAsObservable)
Dec.IsObservable = require(script.Reflection.IsObservable)
Dec.IsState = require(script.Reflection.IsState)
Dec.IsStateRecord = require(script.Reflection.IsStateRecord)
Dec.IsVirtualInstance = require(script.Reflection.IsVirtualInstance)
Dec.GetVirtualInstanceType = require(script.Reflection.GetVirtualInstanceType)

return Dec