--!strict
--[[
    Stores all internal and external Types for Dec
]]
export type Unsubscribe = () -> ()
export type Set<T = any> = {[T]: true}
export type Observable<T = any> = typeof(setmetatable(
	{} :: {
        _lastValue: T,
        _getCurrentUnobserved: () -> T,
        _beginObserving: (update: (value: T) -> ()) -> Unsubscribe,
        _stopObserving: Unsubscribe?,
		_listeners: Set<(newValue: T) -> ()>,
		_destroyed: boolean?,
	},
	{} :: {__index: {
		_dectype: string,
		_decobservabletype: string,
		Subscribe: (self: Observable<T>, listener: (T) -> ()) -> Unsubscribe,
		Current: (self: Observable<T>) -> T,
		Destroy: (self: Observable<T>) -> (),
	}}
))
export type State<T = any> = Observable<T> & typeof(setmetatable(
	{} :: {
		_updateAndNotifyListeners: ((newValue: T) -> ())?,
	},
	{} :: {__index: {
		Set: (self: State<T>, T) -> (),
	}}
))
export type Spring<T = any> = Observable<T> & typeof(setmetatable(
	{} :: {
		_angularFrequency: number,
		_current: T,
		_target: T,
		_snapToGoalTheshold: number?,
	},
	{} :: {__index: {
		_snapToGoalTheshold: number,
		SetAngularFrequency: (self: State<T>, number) -> (),
		CurrentAngularFrequency: (self: State<T>) -> number,
		SetTarget: (self: State<T>, target: T) -> (),
		CurrentTarget: (self: State<T>) -> T,
		SetPosition: (self: State<T>, position: T) -> (),
	}}
))
export type Alpha = Observable<number> & typeof(setmetatable(
	{} :: {},
	{} :: {__index: {
		Slice: (self: Alpha, startAlpha: number, endAlpha: number) -> Alpha,
		Interpolate: (
			self: Alpha,
			easingStyle: Enum.EasingStyle,
			easingDirection: Enum.EasingDirection?
		) -> Alpha
	}}
))
export type BaseTimer = Observable<number> & typeof(setmetatable(
	{} :: {
		_playState: State<{
			playing: boolean,
			startClockTime: number,
			resumeAtElapsed: number,
		}>
	},
	{} :: {__index: {
		Start: (self: BaseTimer) -> (),
		Stop: (self: BaseTimer) -> (),
		Pause: (self: BaseTimer) -> (),
	}}
))
export type Stopwatch = BaseTimer & typeof(setmetatable(
	{} :: { },
	{} :: {__index: {
		Alpha: ((self: Stopwatch, endElapsedTime: number) -> Alpha)
			& ((self: Stopwatch, startElapsedTime: number,
				endElapsedTime: number) -> Alpha),
	}}
))
export type Timer = BaseTimer & typeof(setmetatable(
	{} :: {
		_duration: number,
	},
	{} :: {__index: {
		SetDuration: (self: Timer) -> (),
		Alpha: (
			self: Timer,
			startElapsedTime: number?,
			endElapsedTime: number?
		) -> Alpha,
	}}
))
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
		Properties: (
			self: VirtualInstance,
			propertyMap: {[string]: CanBeObservable<any>}
		) -> (),
		Attributes: (
			self: VirtualInstance,
			attributeMap: {[string]: CanBeObservable<any>}
		) -> (),
		Tags: (
			self: VirtualInstance,
			tags: CanBeObservable<{string}>
		) -> (),
		Connect: (
			self: VirtualInstance,
			eventName: string,
			signal: (...any) -> ()
		) -> (),
		OutProperty: (
			self: VirtualInstance,
			propertyName: string,
			outState: State<any>
		) -> (),
		OutAttribute: (
			self: VirtualInstance,
			propertyName: string,
			outState: State<any>
		) -> (),
		OutInstance: (
			self: VirtualInstance,
			outState: State<Instance> | State<Instance?>
		) -> (),
		Copy: (self: VirtualInstance) -> VirtualInstance,
		DeepCopy: (self: VirtualInstance) -> VirtualInstance,
		Children: (
			self: VirtualInstance,
			childMap: ChildMap
		) -> (),
		Child: (
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
