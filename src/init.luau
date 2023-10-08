--!strict
--[[
    Dec is a reactive UI library for Roblox.

    Dec combines all of the best features of modern libraries like Roact,
    Fusion, and more for building reusable, performant, declarative UI
    components.

    Github Repository: AmberGraceSoftware/Dec
    Wally Package ID: ambergracesoftware/dec
    Documentation: Found on Github
    License: MIT
]]

local Types = require(script.Types)
local Symbols = require(script.Symbols)
local VirtualInstanceCreators = require(script.VirtualInstanceCreators)
local Root = require(script.Reconciler.Root)
local Observable = require(script.Observables.Observable)

export type Unsubscribe = Types.Unsubscribe
export type Observable<T = any> = Types.Observable<T>
export type State<T = any> = Types.State<T>
export type Record<T = {[any]: any}> = Types.StateRecord<T>
export type Dict<K = string, V = any> = Types.StateDict<K, V>
export type Spring<T = any> = Types.Spring<T>
export type AngleSpring<T = any> = Types.AngleSpring<T>
export type IntSpring<T = any> = Types.IntSpring<T>
export type EasedValue<T = any> = Types.EasedValue<T>
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

--[=[
    @class Dec

    :::warning
    Dec is still a work in progress and does not currently have a full release!
    Please avoiding Dec in production-bound projects, as the library is not fully
    tested, and the API may be subject to change
    :::

    The Dec library contains a collection of objects for creating reactive UI
    components
    
    For more information, see the [Usage Guide](../docs/intro)
]=]
local Dec = {}

-- Basic State and Observables
Dec.State = require(script.Observables.State).new
Dec.Record = require(script.Observables.StateRecord).new
Dec.Dict = require(script.Observables.StateRecord).newDict
Dec.Map = require(script.Util.MapObservable)
Dec.CustomObservable = Observable.new
Dec.Clock = require(script.Observables.Clock)

-- Realtime simulation observable utilities
Dec.Spring = require(script.Observables.Spring).new
Dec.IntSpring = require(script.Observables.IntSpring).new
Dec.AngleSpring = require(script.Observables.AngleSpring).new
Dec.Eased = require(script.Observables.Eased).new
Dec.Stopwatch = require(script.Observables.Stopwatch).new
Dec.Timer = require(script.Observables.Timer).new

-- Interop functions
Dec.ObserveFusionState = require(script.Interop.ObserveFusionState)

-- VirtualInstance Creators
Dec.New = VirtualInstanceCreators.New
Dec.Clone = VirtualInstanceCreators.Clone
Dec.Premade = VirtualInstanceCreators.Premade

-- Root-Level Reconciler API
Dec.Root = Root.new

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