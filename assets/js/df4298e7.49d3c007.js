"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9200],{3453:e=>{e.exports=JSON.parse('{"functions":[{"name":"IsVirtualInstance","desc":"This function checks if the passed in value is a Dex VirtualInstance","params":[{"name":"passedIn","desc":"","lua_type":"unknown"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":11,"path":"src/Reflection/IsVirtualInstance.luau"}},{"name":"IsState","desc":"This function checks if the passed in value is a [State] observable object","params":[{"name":"passedIn","desc":"","lua_type":"unknown"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":11,"path":"src/Reflection/IsState.luau"}},{"name":"GetVirtualInstanceType","desc":"This function returns the constructor type for VirtualInstance (\\"New\\",\\n\\"Clone\\", or \\"Premade\\"). Errors if the passed in value is not a\\nVirtualInstance.","params":[{"name":"passedIn","desc":"","lua_type":"VirtualInstance"}],"returns":[{"desc":"","lua_type":"\\"New\\" | \\"Clone\\" | \\"Premade\\""}],"function_type":"static","source":{"line":16,"path":"src/Reflection/GetVirtualInstanceType.luau"}},{"name":"IsObservable","desc":"This function checks if the passed in value is an Observable.","params":[{"name":"passedIn","desc":"","lua_type":"unknown"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":11,"path":"src/Reflection/IsObservable.luau"}},{"name":"IsStateRecord","desc":"This function checks if the passed in value is a [StateRecord] observable\\nobject","params":[{"name":"passedIn","desc":"","lua_type":"unknown"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":12,"path":"src/Reflection/IsStateRecord.luau"}},{"name":"Root","desc":"Creates a new Root instance. The Root is a reference to a real Roblox\\nInstance and is used to reconcile Virtual Instances.","params":[{"name":"hostInstance","desc":"","lua_type":"Instance"}],"returns":[{"desc":"","lua_type":"Root"}],"function_type":"static","source":{"line":110,"path":"src/Reconciler/Root.luau"}},{"name":"Map","desc":"Returns a curryable mapping function, which in turn returns a derived\\nobservable from the dependent observables passed in.\\n\\nExample:\\n```lua\\nlocal x = Dex.State(2)\\nlocal y = Dex.State(3)\\n\\nlocal sum = Dex.Map(x, y)(function(currentX, currentY)\\n    return currentX + currentY\\nend)\\n\\nprint(sum:Current()) -- 5\\n```\\n\\nFor Observables where the values are a vector or scalar type, math\\noperations can be used as an alias for `Dex.Map`!\\n\\nExample:\\n```lua\\nlocal x = Dex.State(2)\\nlocal y = Dex.State(3)\\nlocal sum = x + y\\n\\nprint(sum:Current()) -- 5\\n```","params":[{"name":"...","desc":"","lua_type":"Observable<...T>"}],"returns":[{"desc":"","lua_type":"((map: ...T) -> ReturnType) -> Observable<ReturnType>"}],"function_type":"static","source":{"line":68,"path":"src/Util/MapObservable.luau"}},{"name":"CoerceAsObservable","desc":"This function coerces the passed in value to an Observable. Useful for\\nunwrapped the CanBeObservable<T> type in a component\'s props.","params":[{"name":"value","desc":"","lua_type":"CanBeObservable<T>"}],"returns":[{"desc":"","lua_type":"Observable<T>"}],"function_type":"static","source":{"line":23,"path":"src/Util/CoerceAsObservable.luau"}},{"name":"Spring","desc":"Creates an easing observable that simulates the behavior of a critically\\ndamped spring. The spring simulates in realtime until the target value is\\nreached.\\n\\n:::caution\\nSpring must have at least one Subscriber (or be mounted on at least one\\nVirtualInstance) to simulate in realtime!\\n:::","params":[{"name":"target","desc":"","lua_type":"Observable<T>"},{"name":"angularFrequency","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"Spring<T>"}],"function_type":"static","source":{"line":188,"path":"src/Observables/Spring.luau"}},{"name":"Tween","desc":"Creates a new [Tween] Observable object with the given initial value.","params":[{"name":"initialValue","desc":"","lua_type":"T | Observable<TweenParams<T>>"}],"returns":[{"desc":"","lua_type":"Tween<T>"}],"function_type":"static","source":{"line":196,"path":"src/Observables/Tween.luau"}},{"name":"Dict","desc":"Creates a new Dict state observable with the given initial value.","params":[{"name":"initialValue:","desc":"","lua_type":"{[K]: V}"}],"returns":[{"desc":"","lua_type":"Dict<K, V>"}],"function_type":"static","source":{"line":350,"path":"src/Observables/StateRecord.luau"}},{"name":"Stopwatch","desc":"Creates a new [Stopwatch] Observable, which simulates in realtime while\\nsubscribed.\\n\\n#### Props:\\n\\n`duration` is an optional prop that specifies the end time of the stopwatch.\\nDefaults to `math.huge`.\\n\\n`isPlaying` specifies that stopwatch should play and stop depending on an\\nobservable boolean value. If set to `true`, the stopwatch will immediately\\nstart playing.\\n\\n`playOnChange` specifies that the stopwatch should restart whenever an input\\nobservable changes.","params":[{"name":"props","desc":"","lua_type":"StopwatchProps?"}],"returns":[{"desc":"","lua_type":"Stopwatch"}],"function_type":"static","source":{"line":192,"path":"src/Observables/Stopwatch.luau"}},{"name":"Eased","desc":"Creates an eased Observable that tweens its value in realtime every time\\nthe input Observable changes its value, based on the TweenInfo provided.\\n\\n:::caution\\nEased must have at least one Subscriber (or be mounted on at least one\\nVirtualInstance) to simulate in realtime!\\n:::","params":[{"name":"target","desc":"","lua_type":"Observable<T>"},{"name":"info","desc":"","lua_type":"TweenInfo"}],"returns":[{"desc":"","lua_type":"Eased<T>"}],"function_type":"static","source":{"line":90,"path":"src/Observables/Eased.luau"}},{"name":"State","desc":"Creates a new [State] Observable object with the given initial value.","params":[{"name":"initialValue","desc":"","lua_type":"T"}],"returns":[{"desc":"","lua_type":"State<T>"}],"function_type":"static","source":{"line":88,"path":"src/Observables/State.luau"}},{"name":"IntSpring","desc":"Creates an easing observable that simulates the behavior of a critically\\ndamped spring, constrained to the Integer range. Rounds the current position\\ntowards the target value, which is useful for UI components like currency or\\nammo counters. \\n\\n:::caution\\nSprings must have at least one Subscriber (or be mounted on at least one\\nVirtualInstance) to simulate in realtime!\\n:::","params":[{"name":"target","desc":"","lua_type":"Observable<T>"},{"name":"angularFrequency","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"IntSpring<T>"}],"function_type":"static","source":{"line":117,"path":"src/Observables/IntSpring.luau"}},{"name":"CustomObservable","desc":":::warning\\nConsider opting for other Dex constructs (like State) over custom\\nobservables.\\n\\nWhen writing custom Dex observables, Make sure to implement the `getCurrent`\\nand `createUpdateStream` parameters correctly, as failing to do so may\\ncause memory leaks or unresponsive UI.\\n:::\\n\\nCreates a new Dex Observable object. Observables are used to hold, derive,\\nor map state within a Dex application.\\n\\nThe first parameter should be a function that always returns the current\\nstate of the observable whenever called.\\n\\nFor example, to observe the value of `workspace.CurrentCamera.ViewportSize`:\\n```lua\\nlocal function getCurrent()\\n    return workspace.CurrentCamera.ViewportSize\\nend\\n```\\n\\nThe second parameter is a callback which sets up any event handling required\\nto notify whenever the current state changes, and returns a \\"cleanup\\"\\nfunction to close the event handling.\\n\\nFor example, to observe the value of `workspace.CurrentCamera.ViewportSize`:\\n```lua\\nlocal function createUpdateStream(notifyChange: () -> ())\\n    -- Start tracking changes to ViewportSize, and\\n    -- forward these to the `notifyChange` callback\\n    local connection = workspace.CurrentCamera\\n        :GetPropertyChangedSignal(\\"ViewportSize\\")\\n        :Connect(notifyChange)\\n\\n    -- Return a function which closes the update stream,\\n    -- cleaning up our connection.\\n    return function()\\n        connection:Disconnect()\\n    end\\nend\\n```\\n\\n`createUpdateStream` is automatically called by Dex the first time an\\nobservable is subscribed (or used by a mounted VirtualInstance), and its\\nreturn function to close the update stream is automatically called when the\\nObservable\'s last subscriber is unsubscribed and/or the last VirtualInstance\\nutilizing it is unmounted.\\n\\nPutting it all together, we can create a custom observable which tracks the\\nViewportSize of the player\'s camera:\\n```lua\\nlocal function getCurrent()\\n    return workspace.CurrentCamera.ViewportSize\\nend\\nlocal function createUpdateStream(notifyChange: () -> ())\\n    local connection = workspace.CurrentCamera\\n        :GetPropertyChangedSignal(\\"ViewportSize\\")\\n        :Connect(notifyChange)\\n    \\n    -- closeUpdateStream:\\n    return function()\\n        connection:Disconnect()\\n    end\\nend\\nlocal playerViewportSize = Dex.CustomObservable(\\n    getCurrent,\\n    createUpdateStream\\n)\\nprint(playerViewportSize:Current()) -- Output: 1920, 1080\\n```\\n\\nCustom observables may be useful for connecting third party libraries or\\nother systems in your game\'s codebase to a Dex UI application.","params":[{"name":"getCurrent","desc":"","lua_type":"() -> T"},{"name":"createUpdateStream","desc":"","lua_type":"(notifyChange: () -> ()) -> (() -> ())"}],"returns":[{"desc":"","lua_type":"Observable<T>"}],"function_type":"static","source":{"line":310,"path":"src/Observables/Observable.luau"}},{"name":"Timer","desc":"Creates a new [Timer] Observable, which simulates in realtime while\\nsubscribed.\\n\\n#### Props:\\n\\n`duration` is a required prop that specifies the initial time of the timer.\\n\\n`isPlaying` specifies that timer should play and stop depending on an\\nobservable boolean value. If set to `true`, the timer will immediately start\\nplaying.\\n\\n`playOnChange` specifies that the timer should restart whenever an input\\nobservable changes.","params":[{"name":"props","desc":"","lua_type":"TimerProps"}],"returns":[{"desc":"","lua_type":"Timer"}],"function_type":"static","source":{"line":202,"path":"src/Observables/Timer.luau"}},{"name":"AngleSpring","desc":"Creates an easing observable that simulates the behavior of a critically\\ndamped spring, wrapped around the range [-pi, pi]. The spring simulates in\\nrealtime until the target value is reached.\\n\\n:::caution\\nAngleSpring must have at least one Subscriber (or be mounted on at least one\\nVirtualInstance) to simulate in realtime!\\n:::","params":[{"name":"target","desc":"","lua_type":"Observable<T>"},{"name":"angularFrequency","desc":"","lua_type":"number?"}],"returns":[{"desc":"","lua_type":"AngleSpring<T>"}],"function_type":"static","source":{"line":132,"path":"src/Observables/AngleSpring.luau"}},{"name":"New","desc":"Creates a new [VirtualInstance] that represents a newly-created Roblox\\nInstance (via `Instance.new(className)`).","params":[{"name":"className","desc":"","lua_type":"string"},{"name":"props","desc":"","lua_type":"{[string]: any}?"},{"name":"children","desc":"","lua_type":"{[any]: CanBeObservable<VirtualInstance?>}"}],"returns":[{"desc":"","lua_type":"VirtualInstance"}],"function_type":"static","source":{"line":22,"path":"src/VirtualInstanceCreators.luau"}},{"name":"Clone","desc":"Creates a new [VirtualInstance] that represents a cloned Roblox Instance\\nfrom a given template instance (via `template:Clone()`).","params":[{"name":"template","desc":"","lua_type":"Instance | VirtualInstance"},{"name":"props","desc":"","lua_type":"{[string]: any}?"},{"name":"children","desc":"","lua_type":"{[any]: CanBeObservable<VirtualInstance?>}"}],"returns":[{"desc":"","lua_type":"VirtualInstance"}],"function_type":"static","source":{"line":47,"path":"src/VirtualInstanceCreators.luau"}},{"name":"Premade","desc":"Creates a new VirtualInstance that represents a pre-existing Roblox Instance\\nto be modified by Dex.\\n\\nIf passed into the the Render function for a [Dex.Root] component, the root\\ninstance will be used used.","params":[{"name":"className","desc":"","lua_type":"string"},{"name":"props","desc":"","lua_type":"{[string]: any}?"},{"name":"children","desc":"","lua_type":"{[any]: CanBeObservable<VirtualInstance?>}"}],"returns":[{"desc":"","lua_type":"VirtualInstance"}],"function_type":"static","source":{"line":75,"path":"src/VirtualInstanceCreators.luau"}},{"name":"ObserveFusionState","desc":"Interoperability function that maps a Fusion StateObject to a Dex\\nObservable object. The returned observable is garbage collected once\\ndereferenced and unsubscribed/unmounted.\\n\\nThe Fusion library must be provided, as Fusion StateObjects only work when\\nembedded in a Fusion runtime.","params":[{"name":"Fusion","desc":"","lua_type":"any"},{"name":"fusionStateObject","desc":"","lua_type":"Fusion.StateObject<T>"}],"returns":[{"desc":"","lua_type":"Observable<T>"}],"function_type":"static","source":{"line":22,"path":"src/Interop/ObserveFusionState.luau"}}],"properties":[{"name":"Clock","desc":"Observable number that derives its value from the current time in seconds\\nin UTC (i.e. the value returned by `os.time()`)\\n\\nWhile subscribed, `Dex.Clock` automatically updates its value whenever the\\nvalue of `os.time()` changes.","lua_type":"Observable<number>","source":{"line":15,"path":"src/Observables/Clock.luau"}},{"name":"Nil","desc":"Symbol that represents a \\"Nil\\" value. Because \\"nil\\" values can\'t be\\nrepresented as values of a Luau table, `Dex.Nil` can be used in its place.\\nExample usage:\\n```lua\\nreturn Dex.Premade(\\"BillboardGui\\", {\\n    -- Sets the Adornee property of the premade UI to \\"Nil\\" on mount\\n    Adornee = Dex.Nil,\\n})\\n```","lua_type":"Symbol<\\"Nil\\">","source":{"line":19,"path":"src/Symbols/init.luau"}}],"types":[],"name":"Dex","desc":":::warning\\nDex is still a work in progress and does not currently have a full release!\\nPlease avoiding Dex in production-bound projects, as the library is not fully\\ntested, and the API may be subject to change\\n:::\\n\\nThe Dex library contains a collection of objects for creating reactive UI\\ncomponents\\n\\nFor more information, see the [Usage Guide](../docs/intro)","source":{"line":55,"path":"src/init.luau"}}')}}]);