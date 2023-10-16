--!strict
--[[
    Stores all internal and external Types for Dex
]]
export type Unsubscribe = () -> ()
export type Set<T> = {[T]: true}

export type MappingBinopMetamethod<Simple, Complex> =
    ((lhs: Complex, rhs: Complex) -> Complex)
    & ((lhs: Simple, rhs: Complex) -> Complex)
    & ((lhs: Complex, rhs: Simple) -> Complex)
export type Observable<T> = typeof(setmetatable(
    {} :: {
        _cachedValue: T,
        _getCurrent: () -> T,
        _createUpdateStream: (notifyChange: () -> ()) -> Unsubscribe,
        _closeUpdateStream: Unsubscribe?,
        _listeners: Set<(newValue: T) -> ()>,
        _destroyed: boolean?,
    },
    {} :: {
        __index: {
            _dectype: string,
            _decobservabletype: string,
            Subscribe: (self: Observable<T>, listener: (T) -> (),
                immediatelyCallListener: boolean?) -> Unsubscribe,
            Current: (self: Observable<T>) -> T,
            Destroy: (self: Observable<T>) -> (),
            Map: (self: Observable<T>, mappingFunction: (T) -> any) -> any,
        },
        __mul: MappingBinopMetamethod<T, Observable<T>>,
        __add: MappingBinopMetamethod<T, Observable<T>>,
        __sub: MappingBinopMetamethod<T, Observable<T>>,
        __div: MappingBinopMetamethod<T, Observable<T>>,
        __pow: MappingBinopMetamethod<T, Observable<T>>,
        __unm: (self: Observable<T>) -> Observable<T>,
    }
))
export type State<T> = Observable<T> & typeof(setmetatable(
    {} :: {
        _valueRef: {value: T},
        _notifyUpdate: (() -> ())?,
    },
    {} :: {__index: {
        Set: (self: State<T>, T) -> (),
    }}
))
export type StateRecord<T> = Observable<T> & typeof(setmetatable(
    {} :: {
        _valueRef: {value: T},
        _notifyUpdate: (() -> ())?,
        _notifyRecord: {[any]: {[() -> ()]: true}}
    },
    {} :: {__index: {
        Set: (self: StateRecord<T>, key: any, newValue: any) -> (),
        Current: (self: StateRecord<T>, atKey: any) -> any,
        Replace: (self: StateRecord<T>, T) -> (),
        Index: (self: StateRecord<T>, key: any) -> State<any>,
    }}
))
export type StateDict<K, V> = Observable<{[K]: V}> & typeof(setmetatable(
    {} :: {
        _valueRef: {value: {[K]: V}},
        _notifyUpdate: (() -> ())?,
        _notifyRecord: {[K]: {[() -> ()]: true}}
    },
    {} :: {__index: {
        Set: (self: StateDict<K, V>, key: any, newValue: any) -> (),
        Current: ((self: StateDict<K, V>, atKey: K) -> V)
            & ((self: StateDict<K, V>) -> {[K]: V}),
        Replace: (self: StateDict<K, V>, {[K]: V}) -> (),
        Index: (self: StateDict<K, V>, key: K) -> State<V>,
    }}
))
export type EasedObject<T> = Observable<T> & typeof(setmetatable(
    {} :: {
        _target: Observable<T>,
        _easingFrame: any,
    },
    {} :: {__index: {
        CurrentTarget: (self: EasedObject<T>) -> T,
        SetPosition: (self: EasedObject<T>, position: T) -> (),
        ResetVelocity: (self: EasedObject<T>) -> (),
    }}
))
export type Spring<T> = EasedObject<T> & typeof(setmetatable(
    {} :: {
        _angularFrequency: any, -- CanBeObservable<number>
    },
    {} :: {__index: { }}
))
export type AngleSpring<T> = Spring<T>
export type IntSpring<T> = Spring<T>
export type EasedValue<T> = EasedObject<T> & typeof(setmetatable(
    {} :: {
        _info: TweenInfo,
    },
    {} :: {__index: { }}
))
export type BaseTimer = Observable<number> & typeof(setmetatable(
    {} :: {
        -- Public
        Looped: boolean,
        -- Private
        _duration: number,
        _playState: State<{
            playing: boolean,
            startClockTime: number,
            resumeAtTime: number,
        }>,
        _startReactiveControlStream: (notifyUpdate: () -> ()) -> (() -> ())
    },
    {} :: {__index: {
        Play: (self: BaseTimer) -> (),
        Stop: (self: BaseTimer) -> (),
        Pause: (self: BaseTimer) -> (),
        SetTimePosition: (self: BaseTimer, position: number) -> (),
        Lerp: <T>(
            self: BaseTimer,
            startValue: T,
            goalValue: T
        ) -> Observable<T>,
        Alpha: (
            self: BaseTimer,
            startTime: number,
            endTime: number
        ) -> Observable<number>
    }}
))
export type TweenParams<T> = {
    info: TweenInfo,
    goal: T,
    start: T?,
    completed: (() -> ())?,
    cancelled: (() -> ())?,
}
export type Tween<T> = Observable<T> & typeof(setmetatable(
    {} :: {
        _lastDispatch: State<{
            params: TweenParams<T>,
            startClockTime: number,
            duration: number,
            completed: boolean,
        }>
    },
    {} :: {__index: {
        Play: (self: Tween<T>, props: TweenParams<T>) -> (),
    }}
))
export type Stopwatch = BaseTimer
export type Timer = BaseTimer
export type CanBeObservable<T = any> = T | Observable<T>
export type StopwatchProps = {
    duration: number?,
    isPlaying: CanBeObservable<boolean>?,
    playOnChange: Observable<any>?,
}
export type TimerProps = {
    duration: number,
    isPlaying: CanBeObservable<boolean>?,
    playOnChange: Observable<any>?,
}
export type ChildPath = string | number
export type ChildMap = CanBeObservable<{
    [any]: any--[[[ChildPath]: CanBeObservable<
        VirtualInstance | nil
    >]]
}>
export type VirtualInstanceTrace = {
    method: string,
    source: string?,
    traceback: {{
        identifier: string,
        line: number,
    }}
}
export type VirtualInstanceDirective = {
    _type: string,
    _payload: any,
    _trace: VirtualInstanceTrace?,
}
export type VirtualInstance = typeof(setmetatable(
    {} :: {
        _current: Instance?,
        _constructorType: string,
        _constructorTypeArgument: any,
        _combinedIsAChecks: {{
            className: string,
            trace: VirtualInstanceTrace?,
        }}?,
        _directives: {VirtualInstanceDirective},
        _reconciledNode: ReconciledNode?,
        _onReconciledNodeCallbacks: {[(ReconciledNode) -> ()]: boolean},
    },
    {} :: {__index: {
        _dectype: string,
        SetProperties: (
            self: VirtualInstance,
            propertyMap: {[string]: any}
        ) -> (),
        SetAttributes: (
            self: VirtualInstance,
            attributeMap: {[string]: any}
        ) -> (),
        AddTags: (
            self: VirtualInstance,
            tags: any
        ) -> (),
        Connect: (
            self: VirtualInstance,
            eventName: string,
            signal: (...any) -> ()
        ) -> (),
        OutProperty: (<T>(
            self: VirtualInstance,
            propertyName: string,
            initializedValue: T
        ) -> Observable<T>) & (
            self: VirtualInstance,
            propertyName: string
        ) -> Observable<any?>,
        OutInitialProperty: (<T>(
            self: VirtualInstance,
            propertyName: string,
            initializedValue: T
        ) -> Observable<T>) & (
            self: VirtualInstance,
            propertyName: string
        ) -> Observable<any?>,
        OutAttribute: (<T>(
            self: VirtualInstance,
            attributeName: string,
            initializedValue: T
        ) -> Observable<T>) & (
            self: VirtualInstance,
            attributeName: string
        ) -> Observable<any?>,
        OutInitialAttribute: (<T>(
            self: VirtualInstance,
            propertyName: string,
            initializedValue: T
        ) -> Observable<T>) & (
            self: VirtualInstance,
            attributeName: string
        ) -> Observable<any?>,
        OutInstance: (
            self: VirtualInstance
        ) -> Observable<any?>,
        AddChildren: (
            self: VirtualInstance,
            childMap: ChildMap
        ) -> (),
        MapChildren: <K, V>(
            self: VirtualInstance,
            input: Observable<{[K]: V}>,
            map: (key: K, value: V) -> any?
        ) -> (),
        MapChildrenByKey: <K, V>(
            self: VirtualInstance,
            input: Observable<{[K]: V}>,
            map: (key: K, value: Observable<V>) -> any?
        ) -> (),
        MapChildrenByValue: <K, V>(
            self: VirtualInstance,
            input: Observable<{[K]: V}>,
            map: (value: V, key: Observable<K>) -> any?
        ) -> (),
        FindChild: (
            self: VirtualInstance,
            className: string,
            childPath: ChildPath
        ) -> VirtualInstance,
        AddChild: (
            self: VirtualInstance,
            path: ChildPath,
            child: CanBeObservable<any>
        ) -> (),
        DestroyPremadeChildren: (
            self: VirtualInstance,
            filter: nil | string | ((child: Instance) -> boolean)
        ) -> (),
        OnMount: (
            self: VirtualInstance,
            callback: () -> ()
        ) -> (),
        OnUnmount: (
            self: VirtualInstance,
            callback: () -> ()
        ) -> (),
        Combine: (
            self: VirtualInstance,
            ...VirtualInstance
        ) -> (),
        SubscribeWhileMounted: <T>(
            self: VirtualInstance,
            input: Observable<T>,
            listener: (T) -> (),
            immediatelyCallListener: boolean?
        ) -> (),
    }}
))
export type ReconciledNode = {
    _connections: {RBXScriptConnection},
    _unsubscribes: {Unsubscribe},
    _instancesToCleanup: {Instance},
    _instance: Instance?,
    _instanceResolvedCallbacks: {[(Instance) -> ()]: boolean},
    _rootInstance: Instance,
    _childPath: string?,
    _dectype: string,
    _childMap: {[string]: ReconciledNode},
    _childCleanups: {[string]: () -> ()},
}
export type Symbol<Name> = typeof(setmetatable(
    {} :: {
        _name: Name,
        _usage: string?,
    },
    {} :: {__index: {
        _dectype: string,
    }, __tostring: (self: Symbol<Name>) -> string}
))
export type Root = typeof(setmetatable(
    {} :: {
        _instance: Instance,
        _reconciled: ReconciledNode?
    },
    {} :: {__index: {
        _dectype: string,
        Render: (self: Root, node: VirtualInstance) -> ReconciledNode,
        Unmount: (self: Root) -> (),
        Destroy: (self: Root) -> (),
    }}
))

return nil
