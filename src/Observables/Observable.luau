--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsObservable = require(ReplicatedStorage.Packages.Dec.Reflection.IsObservable)
local Types = require(script.Parent.Parent.Types)

export type Observable<T> = Types.Observable<T>
export type Unsubscribe = Types.Unsubscribe

--[=[
    @class Observable

    Observables are objects that resolve to some value, and can be subscribed to
    detect updates whenver this value changes.

    When setting a [VirtualInstance]'s properties to an Observable, the
    properties in the mounted instance will automatically be updated by Dec to
    match the current value of the observable whenever its value changes.

    An observable will automatically be garbage collected so long as there are
    no listeners are currently subscribed to it, and it is not currently being
    used by a mounted VirtualInstance.
    
    ## Constructor

    ---

    Observable is just the base class for a number of available subclasses, such
    as [State], [Stopwatch], [Dict], [Alpha], etc.

    Using Custom Observables should only be done with caution

    ### Dec.CustomObservable

    ```ts
    Dec.CustomObservable<T>(
        getCurrent: () -> T,
        createUpdateStream: (notifyChange: () -> ()) -> (() -> ())
    ) -> Observable<T>
    ```

    #### See: [Dec.CustomObservable] for full documentation

    :::caution
    Read the full [Dec.CustomObservable] documentation before writing Custom
    Observables; otherwise, opt for other subclasses such as [State].
    :::
]=]
local Observable = {}
Observable.__index = {}
Observable.__index._dectype = "Observable"
Observable.__index._decobservabletype = "Observable"
Observable.__index._ignoreRedundantUpdates = true

-- Safely calls a set of listeners. Listeners can remove themselves from the set
-- during the call without causing issues.
local function callListenersSafe(listenerSet: {[(any) -> ()]: true}, arg: any)
    local listenerList = {}
    for listener in listenerSet do
        table.insert(listenerList, listener)
    end

    for _, listener in ipairs(listenerList) do
        if listenerSet[listener] then
            task.spawn(listener, arg)
        end
    end
end
local function beginObservingIdempotent(self: Observable<any>)
    if self._destroyed then
        return
    end
    if self._closeUpdateStream then
        return
    end
    task.spawn(function()
        local function notifyUpdate()
            local newValue = self._getCurrent()
            if (self :: any)._ignoreRedundantUpdates
                and (self._cachedValue == newValue) then
                return
            end
            self._cachedValue = newValue
            callListenersSafe(self._listeners, newValue)
        end
        self._cachedValue = self._getCurrent()
        self._closeUpdateStream = self._createUpdateStream(notifyUpdate)
    end)
end
local function stopObservingIdempotent(self: Observable<any>)
    if not self._closeUpdateStream then
        return
    end
    self._closeUpdateStream()
    self._closeUpdateStream = nil
end

--[=[
    @method Current
    @within Observable
    @return T

    Returns the current value of the Observable.
]=]
function Observable.__index.Current(self: Observable<any>): any
    if self._closeUpdateStream then
        return self._cachedValue
    else
        return self._getCurrent()
    end
end

--[=[
    @method Map
    @within Observable
    @param mappingFunction (value: T) -> any
    @return Observable<any>

    Creates a new Observable that derives its value from this Observable, using
    a mapping function in the domain of this Observable's value

    Example of mapping a number to a currency display value:
    ```lua
    local money = Dec.State(3)

    local moneyFormatted = money:Map(function(currentMoney)
        return string.format("$%0.2f", currentMoney)
    end)

    print(moneyFormatted:Current()) -- $3.00
    ```
]=]
function Observable.__index.Map(
    self: Observable<any>,
    mappingFunction: (value: any) -> any
): Observable<any>
    -- Lazy-load to prevent circular dependency.
    local MapObservable = (require :: any)(script.Parent.Parent.Util.MapObservable)
    return MapObservable(self)(mappingFunction)
end


--[=[
    @method Subscribe
    @within Observable
    @param listener (value: T) -> ()
    @param immediatelyCallListener boolean?
    @return () -> ()

    Subscribes to changes in the Observable. Returns a function that, when
    called, will unsubscribe the listener from the Observable's changes. If
    `true` is provided as a second argument, will also call the listener once
    immediately with the current value of the Observable.

    :::caution
    Make sure you handle the returned "Unsubscribe" function whenever a calling
    `Subscribe`! If you forget to do this, you may encounter memory leaks!
    
    Observables will remain in memory until all listeners are unsubscribed, and
    all VirtualInstances using it are unmounted
    ```lua
    -- A new Observable can always be garbage collected if dereferenced
    local coins = createCoinsObserver()

    -- However, once we subscribe to it, it will stick
    -- around in memory until we call Unsubscribe!
    local unsubscribe = coins:Subscribe(function(value)
        print("Coins is", value)
    end, true)
    task.wait(5)

    -- The "coins" observable can now be garbage collected
    unsubscribe() 
    ```
    :::
]=]
function Observable.__index.Subscribe(
    self: Observable<any>,
    listener: (value: any) -> (),
    immediatelyCallListener: boolean?
): Unsubscribe
    if self._destroyed then
        error("Cannot subscribe to destroyed Observable")
    end

    beginObservingIdempotent(self)
    self._listeners[listener] = true

    if immediatelyCallListener then
        task.spawn(listener, self:Current())
    end

    local unsubscribed = false
    return function()
        if unsubscribed then
            return
        end
        unsubscribed = true
        self._listeners[listener] = nil
        if not next(self._listeners) then
            stopObservingIdempotent(self)
        end
    end
end

--[=[
    @method SubscribeWhileMounted
    @within Observable
    @param virtualInstance: VirtualInstance
    @param listener (value: T) -> ()
    @param immediatelyCallListenerOnMount boolean?

    Subscribes a custom listener to the observable's value while a
    VirtualInstance is mounted, and automatically unsubscribes the listener when
    the VirtualInstance unmounts.

    :::tip
    SubscribeWhileMounted is much safer than calling [Observable:Subscribe]
    directly, as you do not need to handle an unsubscribe function manually to
    prevent memory leaks.

    You can use this function to trigger side effects such as animations
    whenever an observable value changes:
    ```lua
    local function PulseAnimation(valueToWatch: Dec.Observable)
        -- Create a UIScale object that plays a 1-second "pulse" animation
        -- whenever a stopwatch is played.
        local stopwatch = Dec.Stopwatch(1)
        local uiScale = Dec.New("UIScale", {
            Scale = stopwatch:Map(function(currentTime)
                return 1 + (0.5 - currentTime) * 0.1
            end)
        })

        -- Play the stopwatch whenever the valueToWatch observable changes.
        valueToWatch:SubscribeWhileMounted(uiScale, function()
            stopwatch:Start()
        end)

        return uiScale
    end
    ```
    :::
]=]
function Observable.__index.SubscribeWhileMounted(
    self: Observable<any>,
    virtualInstance: Types.VirtualInstance,
    listener: (value: any) -> (),
    immediatelyCallListenerOnMount: boolean?
): ()
    local unsubscribe: (() -> ())? = nil
    virtualInstance:OnMount(function()
        unsubscribe = self:Subscribe(listener, immediatelyCallListenerOnMount)
    end)
    virtualInstance:OnUnmount(function()
        if unsubscribe then
            unsubscribe()
        end
    end)
end

--[=[
    @method Destroy
    @within Observable
    Destroys the Observable, releasing all its resources and unsubscribing all
    listeners. All further [Observable:Subscribe] calls will error.
]=]
function Observable.__index.Destroy(self: Observable<any>)
    if self._destroyed then
        return
    end
    self._destroyed = true
    stopObservingIdempotent(self)
    self._listeners = {}
end

--[=[
    @function CustomObservable
    @within Dec
    @param getCurrent () -> T
    @param createUpdateStream (notifyChange: () -> ()) -> (() -> ())
    @return Observable<T>


    :::warning
    Consider opting for other Dec constructs (like State) over custom
    observables.
    
    When writing custom Dec observables, Make sure to implement the `getCurrent`
    and `createUpdateStream` parameters correctly, as failing to do so may
    cause memory leaks or unresponsive UI.
    :::

    Creates a new Dec Observable object. Observables are used to hold, derive,
    or map state within a Dec application.

    The first parameter should be a function that always returns the current
    state of the observable whenever called.

    For example, to observe the value of `workspace.CurrentCamera.ViewportSize`:
    ```lua
    local function getCurrent()
        return workspace.CurrentCamera.ViewportSize
    end
    ```
    
    The second parameter is a callback which sets up any event handling required
    to notify whenever the current state changes, and returns a "cleanup"
    function to close the event handling.
    
    For example, to observe the value of `workspace.CurrentCamera.ViewportSize`:
    ```lua
    local function createUpdateStream(notifyChange: () -> ())
        -- Start tracking changes to ViewportSize, and
        -- forward these to the `notifyChange` callback
        local connection = workspace.CurrentCamera
            :GetPropertyChangedSignal("ViewportSize")
            :Connect(notifyChange)

        -- Return a function which closes the update stream,
        -- cleaning up our connection.
        return function()
            connection:Disconnect()
        end
    end
    ```

    `createUpdateStream` is automatically called by Dec the first time an
    observable is subscribed (or used by a mounted VirtualInstance), and its
    return function to close the update stream is automatically called when the
    Observable's last subscriber is unsubscribed and/or the last VirtualInstance
    utilizing it is unmounted.

    Putting it all together, we can create a custom observable which tracks the
    ViewportSize of the player's camera:
    ```lua
    local function getCurrent()
        return workspace.CurrentCamera.ViewportSize
    end
    local function createUpdateStream(notifyChange: () -> ())
        local connection = workspace.CurrentCamera
            :GetPropertyChangedSignal("ViewportSize")
            :Connect(notifyChange)
        
        -- closeUpdateStream:
        return function()
            connection:Disconnect()
        end
    end
    local playerViewportSize = Dec.CustomObservable(
        getCurrent,
        createUpdateStream
    )
    print(playerViewportSize:Current()) -- Output: 1920, 1080
    ```

    Custom observables may be useful for connecting third party libraries or
    other systems in your game's codebase to a Dec UI application.
]=]
function Observable.new<T>(
    getCurrent: () -> T,
    createUpdateStream: (notifyChange: () -> ()) -> Unsubscribe
): Observable<T>
    return setmetatable({
        _cachedValue = getCurrent(),
        _getCurrent = getCurrent,
        _closeUpdateStream = nil :: Unsubscribe?,
        _createUpdateStream = createUpdateStream,
        _listeners = {},
    }, Observable) :: any
end
-- Metamethod implementations: Map lhs and rhs with component-wise binop if the
-- observable value type is a scalar, vector, or matrix
local typeToMonadicBinopMapper: {
    [string]: (a: any, b: any, map: (number, number) -> number) -> any
} = {}
local typeToUnaryNegation: {[string]: (a: any) -> any} = {}

typeToMonadicBinopMapper.number = function(a: number, b: number, map): number
    return map(a, b)
end
typeToUnaryNegation.number = function(self: number)
    return -self
end

typeToMonadicBinopMapper.Vector2 = function(a: Vector2, b: Vector2,
    map): Vector2
    return Vector2.new(map(a.X, b.X), map(a.Y, b.Y))
end
typeToUnaryNegation.Vector2 = function(self: Vector2)
    return -self
end

typeToMonadicBinopMapper.Vector2int16 = function(a: Vector2int16,
    b: Vector2int16, map): Vector2int16
    return Vector2int16.new(map(a.X, b.X), map(a.Y, b.Y))
end
typeToUnaryNegation.Vector2int16 = function(self: Vector2int16)
    return -self
end

typeToMonadicBinopMapper.Vector3 = function(a, b, map)
    return map(a, b) -- Will error if invalid Vector3 binops are used
end
typeToUnaryNegation.Vector3 = function(self: Vector3)
    return -self
end

typeToMonadicBinopMapper.Vector3int16 = function(a: Vector3int16,
    b: Vector3int16, map): Vector3int16
    return Vector3int16.new(map(a.X, b.X), map(a.Y, b.Y), map(a.Z, b.Z))
end
typeToUnaryNegation.Vector3int16 = function(self: Vector3int16)
    return -self
end

typeToMonadicBinopMapper.CFrame = function(a, b, map)
    return map(a, b) -- Will error if invalid CFrame binops are used
end

typeToMonadicBinopMapper.UDim = function(a: UDim, b: UDim, map): UDim
    return UDim.new(map(a.Scale, b.Scale), map(a.Offset, b.Offset))
end
typeToUnaryNegation.UDim = function(self: UDim)
    return UDim.new(-self.Scale, -self.Offset)
end

typeToMonadicBinopMapper.UDim2 = function(a: UDim2, b: UDim2, map): UDim2
    return UDim2.new(
        map(a.X.Scale, b.X.Scale),
        map(a.X.Offset, b.X.Offset),
        map(a.Y.Scale, b.Y.Scale),
        map(a.Y.Offset, b.Y.Offset)
    )
end
typeToUnaryNegation.UDim2 = function(self: UDim2)
    return UDim2.new(
        -self.X.Scale, -self.X.Offset,
        -self.Y.Scale,-self.Y.Offset
    )
end

typeToMonadicBinopMapper.Color3 = function(a: Color3, b: Color3, map): Color3
    return Color3.new(map(a.R, b.R), map(a.G, b.G), map(a.B, b.B))
end
typeToUnaryNegation.Color3 = function(self: Color3)
    return Color3.new(-self.R, -self.G, -self.B)
end

typeToMonadicBinopMapper.boolean = function(a: boolean, b: boolean): boolean
    return a and b
end
typeToUnaryNegation.boolean = function(self: boolean)
    return not self
end

typeToMonadicBinopMapper.Rect = function(a: Rect, b: Rect, map): Rect
    return Rect.new(
        map(a.Min.X, b.Min.X),
        map(a.Min.Y, b.Min.Y),
        map(a.Max.X, b.Max.X),
        map(a.Max.Y, b.Max.Y)
    )
end
typeToUnaryNegation.Rect = function(self: Rect)
    return Rect.new(-self.Min.X, -self.Min.Y, -self.Max.X, -self.Max.Y)
end
-- Monadic method of wrapping and unwrapping vector types into scalar types for
-- metamethod overloads
local function applyBinopPolymorphic(
    a: any,
    b: any,
    binop: (a: number, b: number) -> number
): any
    if typeof(a) ~= typeof(b) then
        error("Can only perform math operations on Dec Observables of the " .. 
            "same type (got " .. typeof(a) .. " and " .. typeof(b) .. ")")
    end
    local monadicMapper = typeToMonadicBinopMapper[typeof(a)]
    if not monadicMapper then
        error("Can only perform math operations on Dec Observables with " .. 
            "scalar, vector, or matrix value types (got " .. typeof(a) ..  ")")
    end

    return monadicMapper(a, b, binop)
end
local function createMappingMetamethod(
    binop: (a: number, b: number) -> number
): (any, any) -> any
    return function(a, b)
        if IsObservable(a) then
            if IsObservable(b) then
                -- Map from two constant observables
                return Observable.new(function()
                    return applyBinopPolymorphic(
                        a:Current(),
                        b:Current(),
                        binop
                    )
                end, function(notifyUpdates)
                    local unsubscribeA = a:Subscribe(notifyUpdates)
                    local unsubscribeB = b:Subscribe(notifyUpdates)
                    return function()
                        unsubscribeA()
                        unsubscribeB()
                    end
                end)
            else
                -- lhs is observable, rhs is constant
                return a:Map(function(aCurrent)
                    return applyBinopPolymorphic(aCurrent, b, binop)
                end)
            end
        else
            -- rhs is observable, lhs is constant
            return b:Map(function(bCurrent)
                return applyBinopPolymorphic(a, bCurrent, binop)
            end)
        end
    end
end
Observable.__add = createMappingMetamethod(function(a, b)
    return a + b
end)
Observable.__sub = createMappingMetamethod(function(a, b)
    return a - b
end)
Observable.__mul = createMappingMetamethod(function(a, b)
    return a * b
end)
Observable.__div = createMappingMetamethod(function(a, b)
    return a / b
end)
Observable.__pow = createMappingMetamethod(function(a, b)
    return a ^ b
end)
Observable.__unm = function(self: Observable<any>)
    local negationHandler = typeToUnaryNegation[typeof(self._cachedValue)]
    if not negationHandler then
        error(
            "Unary negation not supported with Observables of value type"
                .. typeof(self._cachedValue)
        )
    end

    return self:Map(negationHandler)
end

return Observable
