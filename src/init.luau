--!strict
--[[
    Dex is a reactive UI library for Roblox.

    Dex combines all of the best features of modern libraries like Roact,
    Fusion, and more for building reusable, performant, declarative UI
    components.

    Github Repository: AmberGraceSoftware/Dex
    Wally Package ID: ambergracesoftware/dex
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
    @class Dex

    :::warning
    Dex is still a work in progress and does not currently have a full release!
    Please avoiding Dex in production-bound projects, as the library is not fully
    tested, and the API may be subject to change
    :::

    The Dex library contains a collection of objects for creating reactive UI
    components
    
    For more information, see the [Usage Guide](../docs/intro)
]=]
local Dex = {}

-- Basic State and Observables
Dex.State = require(script.Observables.State).new
Dex.Record = require(script.Observables.StateRecord).new
Dex.Dict = require(script.Observables.StateRecord).newDict
Dex.Map = require(script.Util.MapObservable)
Dex.FlattenObservable = require(script.Util.FlattenObservable)
Dex.CustomObservable = Observable.new
Dex.Clock = require(script.Observables.Clock)

-- Realtime simulation observable utilities
Dex.Spring = require(script.Observables.Spring).new
Dex.IntSpring = require(script.Observables.IntSpring).new
Dex.AngleSpring = require(script.Observables.AngleSpring).new
Dex.Eased = require(script.Observables.Eased).new
Dex.Stopwatch = require(script.Observables.Stopwatch).new
Dex.Timer = require(script.Observables.Timer).new

-- Interop functions
Dex.ObserveFusionState = require(script.Interop.ObserveFusionState)

-- VirtualInstance Creators
Dex.New = VirtualInstanceCreators.New
Dex.Clone = VirtualInstanceCreators.Clone
Dex.Premade = VirtualInstanceCreators.Premade

-- Root-Level Reconciler API
Dex.Root = Root.new

-- Symbols
Dex.Nil = Symbols.Nil

-- Reflection
Dex.CoerceAsObservable = require(script.Util.CoerceAsObservable)
Dex.IsObservable = require(script.Reflection.IsObservable)
Dex.IsState = require(script.Reflection.IsState)
Dex.IsStateRecord = require(script.Reflection.IsStateRecord)
Dex.IsVirtualInstance = require(script.Reflection.IsVirtualInstance)
Dex.GetVirtualInstanceType = require(script.Reflection.GetVirtualInstanceType)

return Dex