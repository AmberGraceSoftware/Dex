--!strict
--[[
    Stores all internal and external Types for Dec
]]
export type Unsubscribe = () -> ()
export type Set<T = any> = {[T]: true}
export type Observable<T = any> = typeof(setmetatable(
	{} :: {
		_consumers: Set<any>?,
		_consumersWeak: Set<any>?,
		_current: T,
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
	{} :: {},
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
			easingStyle: Enum.EasingStyle?,
			easingDirection: Enum.EasingDirection?
		) -> Alpha
	}}
))
export type BaseTimer = Observable<number> & typeof(setmetatable(
	{} :: {
		_stepConnection: RBXScriptConnection?,
		_resumeAt: number?,
	},
	{} :: {__index: {
		Start: (self: BaseTimer) -> (),
		Stop: (self: BaseTimer) -> (),
		Pause: (self: BaseTimer) -> (),
		Resume: (self: BaseTimer) -> (),
	}}
))
export type Stopwatch = BaseTimer & typeof(setmetatable(
	{} :: { },
	{} :: {__index: {
		Alpha: (self: Stopwatch, endElapsedTime: number) -> Alpha,
	}}
))
export type Timer = BaseTimer & typeof(setmetatable(
	{} :: {
		_duration: number,
	},
	{} :: {__index: {
		SetDuration: (self: Timer) -> (),
		Alpha: (self: Timer) -> Alpha,
	}}
))
export type CanBeObservable<T = any> = T | Observable<T>
export type TweenState = Observable<{
	info: TweenInfo,
	startProps: {[string]: any}?,
	goalProps: {[string]: any},
	completed: (() -> ())?,
}> & typeof(setmetatable(
	{} :: {
		_currentTween: Tween?,
	},
	{} :: {__index: {
		Start: (self: TweenState) -> (),
		Cancel: (self: TweenState) -> (),
		SetGoal: (self: TweenState, goalProps: {[string]: any}) -> (),
		SetInfo: (self: TweenState, info: TweenInfo) -> (),
		SetStart: (self: TweenState, startProps: {[string]: any}?) -> (),
		SetOnCompleted: (self: TweenState, cb: (() -> ())?) -> (),
	}}
))
export type VirtualInstance = typeof(setmetatable(
	{} :: {
		_current: Instance?,
		_directives: {any},
	},
	{} :: {__index: {
		_dectype: string,
		Properties: (
			self: VirtualInstance,
			propertyMap: CanBeObservable<{[string]: any}>
		) -> (),
		Tweens: (
			self: VirtualInstance,
			TweenState | {TweenState}
		) -> (),
		Attributes: (
			self: VirtualInstance,
			attributeMap: CanBeObservable<{[string]: any}>
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
			childMap: CanBeObservable<{
				[string | {string} | number]: CanBeObservable<
					Instance | VirtualInstance | nil
				>
			}>
		) -> (),
		Child: (
			self: VirtualInstance,
			path: CanBeObservable<string | {string}>,
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
	}, __call: (
		self: VirtualInstance,
		propertyMap: CanBeObservable<{[string]: any}>
	) -> VirtualInstance}
))
export type ReconciledNode = typeof(setmetatable(
	{} :: {
		_connections: {RBXScriptConnection},
		_instances: {Instance},
		_instance: Instance,
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

-- Temporary typedef for library; will move typings to the return of component
-- modules themselves.
type Dec = {
	-- State and Observable Utilities
	State: <T>(initial: T) -> State<T>,
	Spring: <T>(initial: T) -> Spring<T>,
	Stopwatch: () -> Stopwatch,
	Timer: (duration: number) -> Timer,
	Tween: (info: TweenInfo, goalProps: {[string]: any}, startProps: {[string]: any}?) -> TweenState,
	Derive: (<Return, D1>(
		dep1: Observable<D1>,
		map: (dep1: D1) -> Return
	) -> Observable<Return>)
	& (<Return, D1, D2>(
		dep1: Observable<D1>, dep2: Observable<D2>,
		map: (dep1: D1, dep2: D2) -> Return
	) -> Observable<Return>)
	& (<Return, D1, D2, D3>(
		dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
		map: (dep1: D1, dep2: D2, dep3: D3) -> Return
	) -> Observable<Return>)
	& (<Return, D1, D2, D3, D4>(
		dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
		dep4: Observable<D4>,
		map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4) -> Return
	) -> Observable<Return>)
	& (<Return, D1, D2, D3, D4, D5>(
		dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
		dep4: Observable<D4>, dep5: Observable<D4>,
		map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5) -> Return
	) -> Observable<Return>)
	& (<Return, D1, D2, D3, D4, D5, D6>(
		dep1: Observable<D1>, dep2: Observable<D2>, dep3: Observable<D3>,
		dep4: Observable<D4>, dep5: Observable<D4>, dep6: Observable<D4>,
		map: (dep1: D1, dep2: D2, dep3: D3, dep4: D4, dep5: D5,
			dep6: D6) -> Return
	) -> Observable<Return>),
	CoerceAsObservable: <T>(passedIn: T | Observable<T>) -> Observable<T>,
	ObserveFusionState: <T>(
		fusionStateObject: {get: () -> T}
	) -> (Observable<T>, Unsubscribe),
	
	-- VirtualInstance Creators
	New: (className: string) -> VirtualInstance,
	Clone: (template: Instance) -> VirtualInstance,
	Premade: () -> VirtualInstance,
	
	-- Root-Level Reconciler API
	CreateRoot: (instance: Instance) -> Root,
	
	-- Symbols
	Nil: Symbol<"Nil">,
}

return nil
