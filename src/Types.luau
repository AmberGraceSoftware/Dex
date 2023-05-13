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
		Subscribe: (self: Observable<T>, listener: (T) -> ()) -> Unsubscribe,
		Current: (self: Observable<T>) -> T,
		DeferUpdates: (self: Observable<T>) -> Observable<T>,
		Destroy: (self: Observable<T>) -> (),
	}}
))
export type State<T = any> = Observable<T> & typeof(setmetatable(
	{} :: {},
	{} :: {__index: {
		Set: (self: State<T>, T) -> (),
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
export type Stopwatch = Observable<number> & typeof(setmetatable(
	{} :: {
		_stepConnection: RBXScriptConnection?,
		_resumeAt: number?,
	},
	{} :: {__index: {
		Alpha: (self: Stopwatch, endElapsedTime: number) -> Alpha,
		Start: (self: Stopwatch) -> (),
		Stop: (self: Stopwatch) -> (),
		Pause: (self: Stopwatch) -> (),
		Resume: (self: Stopwatch) -> (),
	}}
))
export type Timer = Observable<number> & typeof(setmetatable(
	{} :: {
		_stepConnection: RBXScriptConnection?,
		_resumeAt: number?,
		_duration: Observable<number>,
	},
	{} :: {__index: {
		SetDuration: (self: Timer) -> (),
		Alpha: (self: Timer) -> Alpha,
		Start: (self: Timer) -> (),
		Stop: (self: Timer) -> (),
		Pause: (self: Timer) -> (),
		Resume: (self: Timer) -> (),
	}}
))
export type CanBeObservable<T = any> = T | Observable<T>
export type VirtualInstance = typeof(setmetatable(
	{} :: {
		_current: Instance?,
		_directives: {any},
	},
	{} :: {__index: {
		Assign: (
			self: VirtualInstance,
			propertyMap: {[string]: any}
		) -> VirtualInstance,
		Tween: (
			self: VirtualInstance,
			info: TweenInfo,
			goalProperties: CanBeObservable<{[string]: CanBeObservable<any>}?>,
			startProperties: CanBeObservable<{[string]: CanBeObservable<any>}?>
		) -> VirtualInstance,
		SetAttributes: (
			self: VirtualInstance,
			attributeMap: {[string]: any}
		) -> VirtualInstance,
		SetTags: (
			self: VirtualInstance,
			tags: {string} | Observable<{string}>
		) -> VirtualInstance,
		Connect: (
			self: VirtualInstance,
			eventName: string,
			signal: (...any) -> ()
		) -> VirtualInstance,
		StoreProperty: (
			self: VirtualInstance,
			propertyName: string,
			outState: State<any>
		) -> VirtualInstance,
		StoreAttribute: (
			self: VirtualInstance,
			propertyName: string,
			outState: State<any>
		) -> VirtualInstance,
		StoreReference: (
			self: VirtualInstance,
			outState: State<Instance>
		) -> VirtualInstance,
		Copy: (self: VirtualInstance) -> VirtualInstance,
		AddChildren: (
			self: VirtualInstance,
			childMap: CanBeObservable<{
				[string | number]: CanBeObservable<Instance | VirtualInstance>
			}>
		) -> VirtualInstance,
		AddChild: (
			self: VirtualInstance,
			child: CanBeObservable<Instance | VirtualInstance>,
			name: string?
		) -> VirtualInstance,
		AddExistingChild: (
			self: VirtualInstance,
			path: string | {string},
			callback: CanBeObservable<(VirtualInstance) -> ()>
		) -> VirtualInstance,
		AddToParent: (
			self: VirtualInstance,
			parent: CanBeObservable<VirtualInstance | Instance>
		) -> VirtualInstance,
		-- Lifecycle events (Useful for niche cases like event/effect cleanups
		-- that can't be handled directly via Dec's virtual instances)
		OnUnmount: (
			self: VirtualInstance,
			callback: (instance: Instance) -> ()
		) -> VirtualInstance,
		OnMount: (
			self: VirtualInstance,
			callback: (instance: Instance) -> ()
		) -> VirtualInstance,
		Index: (
			self: VirtualInstance,
			path: string | {string}
		) -> VirtualInstance,
		
		--  Linked states
		CleanupOnUnmount: (
			self: VirtualInstance,
			object: any
		) -> any,
	}, __call: (
		self: VirtualInstance,
		propertyMap: {[string]: any}
	) -> VirtualInstance}
))
export type Reconciled = {
	_connections: {RBXScriptConnection},
	_instances: {Instance},
	_instance: Instance,
}
export type Symbol = typeof(setmetatable(
	{} :: {
		_name: string,
		_usage: string?,
	},
	{} :: {
		__tostring: (self: Symbol) -> string
	}
))

-- Temporary typedef for library; will move typings to the return of component
-- modules themselves.
type Dec = {
	-- State and Observable Utilities
	State: <T>(initial: T) -> State<T>,
	Stopwatch: () -> Stopwatch,
	Timer: (duration: number) -> Timer,
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
	Existing: (template: Instance | VirtualInstance) -> VirtualInstance,
	
	-- Root-Level Reconciler API
	Mount: (root: CanBeObservable<VirtualInstance>) -> Reconciled,
	Replace: (
		current: Reconciled,
		new: CanBeObservable<VirtualInstance>
	) -> VirtualInstance,
	Unmount: (current: Reconciled) -> (),
	
	-- Symbols
	Nil: {}
}

return nil