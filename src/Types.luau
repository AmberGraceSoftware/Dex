--!strict
--[[
    Stores all internal and external Types for Dec
]]
export type Unsubscribe = () -> ()
export type Set<T = any> = {[T]: true}
export type Observable<T = any> = typeof(setmetatable(
    {} :: {
        _cachedValue: T,
        _getCurrent: () -> T,
        _createUpdateStream: (notifyChange: () -> ()) -> Unsubscribe,
        _closeUpdateStream: Unsubscribe?,
        _listeners: Set<(newValue: T) -> ()>,
        _destroyed: boolean?,
    },
    {} :: {__index: {
        _dectype: string,
        _decobservabletype: string,
        Subscribe: (self: Observable<T>, listener: (T) -> ()) -> Unsubscribe,
        Current: (self: Observable<T>) -> T,
        Destroy: (self: Observable<T>) -> (),
        Map: (self: Observable<T>, mappingFunction: (T) -> any) -> any,
    }}
))
export type State<T = any> = Observable<T> & typeof(setmetatable(
    {} :: {
        _notifyUpdate: (() -> ())?,
    },
    {} :: {__index: {
        Set: (self: State<T>, T) -> (),
    }}
))
export type StateRecord<T = any> = Observable<T> & typeof(setmetatable(
    {} :: {
        _notifyUpdate: (() -> ())?,
        _notifyRecord: {[any]: {[() -> ()]: true}}
    },
    {} :: {__index: {
        Set: (self: StateRecord<T>, key: any, newValue: any) -> (),
        Current: (self: StateRecord<T>, atKey: any) -> any,
        Replace: (self: StateRecord<T>, T) -> (),
        Index: (self: StateRecord<T>, key: any) -> Observable<any>,
    }}
))
export type Spring<T = any> = Observable<T> & typeof(setmetatable(
    {} :: {
        _angularFrequency: any, -- CanBeObservable<number>
        _target: Observable<T>,
        _snapToGoalTheshold: any, -- CanBeObservable<number>?
    },
    {} :: {__index: {
        CurrentTarget: (self: State<T>) -> T,
        SetPosition: (self: State<T>, position: T) -> (),
        ResetVelocity: (self: State<T>) -> (),
    }}
))
export type IntSpring<T = any> = Observable<T> & typeof(setmetatable(
    {} :: {
        _angularFrequency: any, -- CanBeObservable<number>
        _target: Observable<T>,
    },
    {} :: {__index: {
        CurrentTarget: (self: State<T>) -> T,
        SetPosition: (self: State<T>, position: T) -> (),
        ResetVelocity: (self: State<T>) -> (),
    }}
))
export type EasedValue<T = any> = Observable<T> & typeof(setmetatable(
    {} :: {
        _info: TweenInfo,
        _target: Observable<T>,
    },
    {} :: {__index: {
        CurrentTarget: (self: State<T>) -> T,
        SetPosition: (self: State<T>, position: T) -> (),
        ResetVelocity: (self: State<T>) -> (),
    }}
))
export type Alpha = Observable<number> & typeof(setmetatable(
    {} :: {},
    {} :: {__index: {
        Slice: (self: Alpha, startAlpha: number, endAlpha: number) -> Alpha,
        Curve: (
            self: Alpha,
            easingStyle: Enum.EasingStyle,
            easingDirection: Enum.EasingDirection?
        ) -> Alpha,
        Lerp: <T>(
            self: Alpha,
            startValue: T,
            goalValue: T
        ) -> Observable<T>,
        Invert: (self: Alpha) -> Alpha,
    }}
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
        }>
    },
    {} :: {__index: {
        Start: (self: BaseTimer) -> (),
        Stop: (self: BaseTimer) -> (),
        Pause: (self: BaseTimer) -> (),
        SetTimePosition: (self: BaseTimer) -> (),
        CurvedAlpha: (
            self: Alpha,
            easingStyle: Enum.EasingStyle,
            easingDirection: Enum.EasingDirection?
        ) -> Alpha,
        SliceAlpha: (
            self: Alpha,
            startTime: number,
            endTime: number
        ) -> Alpha,
        Lerp: <T>(
            self: Alpha,
            startValue: T,
            goalValue: T
        ) -> Observable<T>,
        Alpha: (self: BaseTimer) -> Alpha,
    }}
))
export type Stopwatch = BaseTimer
export type Timer = BaseTimer
export type CanBeObservable<T = any> = T | Observable<T>
export type ChildPath = string | number | {string | number}
export type ChildMap = CanBeObservable<{
    [ChildPath]: CanBeObservable<
        Instance | VirtualInstance | nil
    >
}>
export type VirtualInstanceTrace = {
    method: string,
    source: string?,
    traceback: {{
        identifier: string,
        line: number,
    }}
}
export type VirtualInstance = typeof(setmetatable(
    {} :: {
        _current: Instance?,
        _constructorType: string,
        _constructorTypeArgument: any,
        _directives: {{
            _type: string,
            _payload: any,
            _trace: VirtualInstanceTrace?,
        }},
    },
    {} :: {__index: {
        _dectype: string,
        SetProperties: (
            self: VirtualInstance,
            propertyMap: {[string]: CanBeObservable<any>}
        ) -> (),
        SetAttributes: (
            self: VirtualInstance,
            attributeMap: {[string]: CanBeObservable<any>}
        ) -> (),
        AddTags: (
            self: VirtualInstance,
            tags: CanBeObservable<{string}>
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
        Copy: (self: VirtualInstance) -> VirtualInstance,
        DeepCopy: (self: VirtualInstance) -> VirtualInstance,
        AddChildren: (
            self: VirtualInstance,
            childMap: ChildMap
        ) -> (),
        AddChild: (
            self: VirtualInstance,
            path: ChildPath,
            child: CanBeObservable<Instance | VirtualInstance | nil>
        ) -> (),
        OnMount: (
            self: VirtualInstance,
            callback: (instance: Instance) -> ()
        ) -> (),
        OnUnmount: (
            self: VirtualInstance,
            callback: (instance: Instance) -> ()
        ) -> (),
    }}
))
export type ReconciledNode = typeof(setmetatable(
    {} :: {
        _connections: {RBXScriptConnection},
        _unsubscribes: {Unsubscribe},
        _instances: {Instance},
        _instance: Instance,
        _rootInstance: Instance,
        _childPath: string?,
    },
    {} :: {__index: {
        _dectype: string,
        Destroy: (self: ReconciledNode) -> (),
    }}
))
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
