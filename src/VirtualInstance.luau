--!strict

local Types = require(script.Parent.Types)
local State = require(script.Parent.Observables.State)

type VirtualInstanceTrace = Types.VirtualInstanceTrace
type VirtualInstance = Types.VirtualInstance
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type ChildPath = Types.ChildPath
type ChildMap = Types.ChildMap

local VIRTUAL_INSTANCE_TRACING = true
local DEBUG_MAX_TRACEBACK_LENGTH = 3

local function getTrace(methodName: string, traceLevel: number): VirtualInstanceTrace?
    if not VIRTUAL_INSTANCE_TRACING then
        return nil
    end

    traceLevel += 1

    local source: string? = debug.info(traceLevel, "s")
    local traceback: {{
        identifier: string,
        line: number
    }} = {}
    if source then
        for i = 0, DEBUG_MAX_TRACEBACK_LENGTH - 1 do
            local traceLevelAtIndex = traceLevel + i
            if debug.info(traceLevelAtIndex, "s") ~= source then
                break
            end
            local ident = debug.info(traceLevelAtIndex, "n")
            local line = debug.info(traceLevelAtIndex, "l")
            if not ident or not line then
                break
            end
            table.insert(traceback, {
                identifier = ident,
                line = line,
            })
        end
    end
    local trace: VirtualInstanceTrace? = {
        method = methodName,
        source = source,
        traceback = traceback,
    }
    return trace
end
local function assertNotYetMounted(virtualInstance: VirtualInstance)
    if table.isfrozen(virtualInstance :: any) then
        error(
            "Cannoy modify a VirtualInstance after it has been mounted. " .. 
            "Please verify your code to make sure you are only defining " ..
            "properties, attributes, tags, etc. before mounting the " .. 
            "VirtualInstance (See Dec docs). You should utilize Observables " ..
            "instead of modifying a VirtaulInstance after it is mounted.",
            2
        )
    end
end

--[=[
    @class VirtualInstance
    VirtualInstances are the basic building blocks for Dec applications.

    VirtualInstances are "Mounted" by Dec's reconciler engine,
    creating/destoying/modifying these real instances automatically as needed.

    ## Constructors
    ---

    ### Dec.New
    ```lua
    Dec.New(
        className: string,
        props: {[string]: any}?,
        children: {[any]: CanBeObservable<VirtualInstance?>}
    ) -> VirtualInstance
    ```

    Creates a new [VirtualInstance] that represents a newly-created Roblox
    Instance (via `Instance.new(className)`).

    ---

    ### Dec.Clone
    ```lua
    Dec.Clone(
        template: Instance | VirtualInstance,
        props: {[string]: any}?,
        children: {[any]: CanBeObservable<VirtualInstance?>}
    ) -> VirtualInstance
    ```
    Creates a new [VirtualInstance] that represents a cloned Roblox Instance
    from a given template instance (via `template:Clone()`).

    ---

    ### Dec.Premade
    ```lua
    Dec.Premade(
        className: stirng,
        props: {[string]: any}?,
        children: {[any]: CanBeObservable<VirtualInstance?>}
    ) -> VirtualInstance
    ```

    Creates a new VirtualInstance that represents a pre-existing Roblox Instance
    to be modified by Dec.

    If passed into the the Render function for a [Dec.Root] component, the root
    instance will be used used.
]=]
local VirtualInstance = {}
VirtualInstance.__index = {}
VirtualInstance.__index._dectype = "VirtualInstance"

--[=[
    @method SetProperties
    @within VirtualInstance
    @param propertyMap {[string]: CanBeObservable<any>}

    Adds properties to be rendered on the instance when it is reconciled.

    Multiple calls to this function will merge the provided property map with
    the existing one, prioritizing the later call.

    Values in the propertyMap can have multiple possible types, which are each
    handled differently:

    - A **Static Value** (number, boolean, string, UDim2, etc.) to be assigned
    right as the VirtualInstance is rendered
    - An **Observablue Value** to be assigned as the VirtualInstance is
    Rendered, as well as when the Observable value changes
    - A **`Dec.Nil`** symbol, which assigns a property to `nil` when rendered
    - A **function** which represents a listener to connect to an event while
    the VirtualInstance is rendered
    - Another **VirtualInstance**, which references an instance property to be
    assigned. This is useful for ViewportFrames, for example, where a camera
    must both be created underneath the ViewportFrame, and assigned as the
    CurrentCamera property within the same frame.
]=]
function VirtualInstance.__index.SetProperties(
    self: VirtualInstance,
    propertyMap: {[string]: any}
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Properties",
        _payload = propertyMap,
        _trace = getTrace("VirtualInstance:SetProperties", 1),
    })
end

--[=[
    @method SetAttributes
    @within VirtualInstance
    @param attributeMap {[string]: CanBeObservable<any>}

    Adds attributes to be rendered on the instance when it is reconciled.
    
    Multiple calls to this function will merge the provided attribute map with
    the existing one, prioritizing the latest calls.
]=]
function VirtualInstance.__index.SetAttributes(
    self: VirtualInstance,
    attributeMap: {[string]: CanBeObservable<any>}
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Attributes",
        _payload = attributeMap,
        _trace = getTrace("VirtualInstance:SetAttributes", 1),
    })
end

--[=[
    @method AddTags
    @within VirtualInstance
    @param tags CanBeObservable<{string}>

    Adds tags to the Virtual Instance when it is reconciled. Multiple calls to
    this function will add extra tags to the VirtualInstance if they do not
    exist.
]=]
function VirtualInstance.__index.AddTags(
    self: VirtualInstance,
    tags: CanBeObservable<{string}>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "TagList",
        _payload = tags,
        _trace = getTrace("VirtualInstance:AddTags", 1),
    })
end

--[=[
    @method Connect
    @within VirtualInstance
    @param eventName string
    @param listener (...any) -> ()

    Adds an event listener to the Virtual Instance, which will automatically
    be connected and disconnected as the VirtualInstance is reconciled.
]=]
function VirtualInstance.__index.Connect(
    self: VirtualInstance,
    eventName: string,
    listener: (...any) -> ()
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Connect",
        _payload = {
            event = eventName,
            listener = listener,
        },
        _trace = getTrace("VirtualInstance:Connect", 1),
    })
end

--[=[
    @method OutProperty
    @within VirtualInstance
    @param propName string
    @param initialValue T
    @return Observable<T>

    Creates an Observable object that updates to the current value of an
    property on the virtual instance once when it is mounted, and listens to
    updates on this property.

    Give initialValue a type annotation if initializing to nil
    (e.g. vInst:OutProperty("Adornee", nil :: Instance?)()
]=]
function VirtualInstance.__index.OutProperty(
    self: VirtualInstance,
    propertyName: string,
    initialValue: any
): Observable<any>
    assertNotYetMounted(self)
    local outState = State.new(initialValue)
    table.insert(self._directives, {
        _type = "OutProperty",
        _payload = {
            property = propertyName,
            state = outState,
            once = false,
        },
        _trace = getTrace("VirtualInstance:OutProperty", 1),
    })
    return outState
end

--[=[
    @method OutInitialProperty
    @within VirtualInstance
    @param propName string
    @param initialValue T
    @return Observable<T> - An observable with the same output type as initialValue.

    Creates an Observable object that updates to the original value of an
    property on the virtual instance once when it is mounted. This is useful
    for referencing properties on a premade instance without hardcoding them in
    a Dec component.

    Give initialValue a type annotation if initializing to nil
    (e.g. vInst:OutInitialProperty("Adornee", nil :: Instance?))
]=]
function VirtualInstance.__index.OutInitialProperty(
    self: VirtualInstance,
    propertyName: string,
    initialValue: any
): Observable<any>
    assertNotYetMounted(self)
    local outState = State.new(initialValue)
    table.insert(self._directives, {
        _type = "OutProperty",
        _payload = {
            property = propertyName,
            state = outState,
            once = true,
        },
        _trace = getTrace("VirtualInstance:OutInitialProperty", 1),
    })
    return outState
end

--[=[
    @method OutAttribute
    @within VirtualInstance
    @param attributeName string
    @param initialValue T
    @return Observable<T>

    Creates an Observable object that updates to the current value of an
    attribute on the virtual instance once when it is mounted, and listens to
    updates on this attribute.

    Give initialValue a type annotation if initializing to nil
    (e.g. vInstance:OutAttribute("Foo", nil :: string?))
]=]
function VirtualInstance.__index.OutAttribute(
    self: VirtualInstance,
    propertyName: string,
    initialValue: any
): Observable<any>
    local outState = State.new(initialValue)
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OutAttribute",
        _payload = {
            attribute = propertyName,
            state = outState,
            once = false,
        },
        _trace = getTrace("VirtualInstance:OutAttribute", 1),
    })
    return outState
end

--[=[
    @method OutInitialAttribute
    @within VirtualInstance
    @param attributeName string
    @param initialValue T
    @return Observable<T>

    Creates an Observable object that updates to the original value of an
    attribute on the virtual instance once when it is mounted. This is useful
    for referencing attributes on a premade instance without hardcoding them in
    a Dec component.

    Give initialValue a type annotation if initializing to nil
    (e.g. vInst:OutInitialAttribute("Foo", nil :: string?))
]=]
function VirtualInstance.__index.OutInitialAttribute(
    self: VirtualInstance,
    propertyName: string,
    initialValue: any
): Observable<any>
    local outState = State.new(initialValue)
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OutAttribute",
        _payload = {
            attribute = propertyName,
            state = outState,
            once = true
        },
        _trace = getTrace("VirtualInstance:OutInitialAttribute", 1),
    })
    return outState
end

--[=[
    @method OutInstance
    @within VirtualInstance
    @return Observable<Instance?>

    Outputs a reference to the reconciled instance to a Dec State object.

    :::danger
    Using OutInstance to directly edit the rendered instance's properties may
    lead to unexpected behavior. It is recommended to only use OutInstance where
    no alternatives are available within the Dec API for your use case.

    ## Use Case Alternatives

    ### Preformating an instance
    If an instance requires some amount of preformatting (e.g. deleting children
    of a premade template), you can use the directive
    [VirtualInstance:DestroyPremadeChildren] to destroy template UI elements
    within a design.

    Most other use cases for preformatting can usually be handled through the
    :SetProperties directive.

    ### Using a nested template for [Dec.Clone]
    Dec.Clone supports passing in another _VirtualInstance_ as an argument, as
    long as there are no circular dependencies. This will wait until the
    template VirtualInstance is mounted to instantiate the cloned instance.

    ### OnMount/OnUnmount
    The methods [VirtualInstance:OnMount] and [VirtualInstance.OnUnmont] allow
    side effects to be performed during the VirtualInstance's rendering
    lifecycle. If your use case does not require a direct reference to the
    rendered instance, this may be the best option.
    :::
]=]
function VirtualInstance.__index.OutInstance(
    self: VirtualInstance
): Observable<any?>
    assertNotYetMounted(self)
    local outState = State.new(nil :: Instance?)
    table.insert(self._directives, {
        _type = "OutInstance",
        _payload = outState,
        _trace = getTrace("VirtualInstance:OutInstance", 1),
    })
    return outState
end

--[=[
    @method AddChild
    @within VirtualInstance
    @param path string | number
    @param child CanBeObservable<VirtualInstance?>

    Adds a child VirtualInstance node to this VirtualInstance.

    The path can be a dot-separated string, or an array of raw string names.
    
    If the child is a VirtualInstance, it will be created or found depending on
    the type of VirtualInstance passed in.
]=]
function VirtualInstance.__index.AddChild(
    self: VirtualInstance,
    path: ChildPath,
    child: CanBeObservable<Instance | VirtualInstance | nil>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Children",
        _payload = {[path] = child},
        _trace = getTrace("VirtualInstance:AddChild", 1),
    })
end


--[=[
    @method AddChildren
    @within VirtualInstance
    @param childMap CanBeObservable<{[any]: CanBeObservable<VirtualInstance?>}>

    Adds multiple children to the VirtualInstance given a child map. See
    VirtualInstance:Child() for API reference
]=]
function VirtualInstance.__index.AddChildren(
    self: VirtualInstance,
    childMap: ChildMap
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Children",
        _payload = childMap,
        _trace = getTrace("VirtualInstance:AddChildren", 1),
    })
end

--[=[
    @method MapChildren
    @within VirtualInstance
    @param input Observable<{[K]: V}>
    @param map (key: K, value: V) -> CanBeObservable<VirtualInstance>?

    Creates a child VirtualInstance for each key/value pair of the input
    observable. When a Key/Value pair changes, the existing
    VirtualInstance at that key is destroyed (if it exists), and a new one is
    created (if the value is not `nil`).

    The mapping function should create a single VirtualInstance based on the
    current key and value. 

    This performs better than directly calling [VirtualInstance:AddChildren]
    with an Observable input, as this only creates/destroys virtual instances on
    the specific key/value pairs that have changed whenever the input observable
    updates.

    Example:
    ```lua
    local function ItemList()
        local visibleItemIds = Dec.State({"Sword", "Gun", "MagicStaff"})
        local scrollingFrame = Dec.New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1)
        })
        scrollingFrame:MapChildren(visibleItemIds, function(i, id)
            -- Instantiate a child ItemCard component for this given item ID,
            -- and destroy/re-create a new item card when this ID changes.
            return ItemCard({
                id = id,
                layoutOrder = i,
            })
        end)
        return scollingFrame
    end
    ```
]=]
function VirtualInstance.__index.MapChildren(
    self: VirtualInstance,
    input: Observable<any>,
    map: (key: any, value: any) -> VirtualInstance?
)
    assertNotYetMounted(self)

    table.insert(self._directives, {
        _type = "MapChildren",
        _payload = {
            input = input,
            map = map,
        },
        _trace = getTrace("VirtualInstance:MapChildren", 1),
    })
end

--[=[
    @method MapChildrenByKey
    @within VirtualInstance
    @param input Observable<{[K]: V}>
    @param map (key: K, value: Observable<V>) -> CanBeObservable<VirtualInstance>?

    Creates a child VirtualInstance for each key of the input
    observable. VirtualInstances will only be created/destroyed according to the
    provided mapping function when a new key is added or removed from the table.

    The value is wrapped in an observable, and will forward updates to the
    mapping function when the value at a particlar key changes.

    The mapping function should create a single VirtualInstance based on the
    current key and observable value at that key.
    
    This is useful for instances where the input observable is a "Map", "Set",
    or "Dictionary" type, and may perform better than
    [VirtualInstance:MapChildren] in that case by minimizing
    creation/destruction of virtual instances.

    Example:
    ```lua
    local function ItemList()
        local visibleItemIdSet = Dec.State({
            ["Sword"] = true,
            ["Gun"] = true,
            ["MagicStaff"] = true}
        )
        local scrollingFrame = Dec.New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1)
        })
        scrollingFrame:MapChildrenByKey(visibleItemIds, function(id)
            return ItemCard({
                id = id,
            })
        end)
        return scollingFrame
    end
    ```
]=]
function VirtualInstance.__index.MapChildrenByKey(
    self: VirtualInstance,
    input: Observable<any>,
    map: (key: any, value: Observable<any>) -> VirtualInstance?
)
    assertNotYetMounted(self)

    table.insert(self._directives, {
        _type = "MapChildrenByKey",
        _payload = {
            input = input,
            map = map,
        },
        _trace = getTrace("VirtualInstance:MapChildrenByKey", 1),
    })
end

--[=[
    @method MapChildrenByValue
    @within VirtualInstance
    @param input Observable<{[K]: V}>
    @param map (value: V, key: Observable<K>) -> CanBeObservable<VirtualInstance>?

    Creates a child VirtualInstance for each value of the input
    observable. VirtualInstances will only be created/destroyed according to the
    provided mapping function when a new value is added or removed from the
    table.

    In the case of duplicate values, the last key/value pair defined in the
    input table will be considered.

    The key is wrapped in an observable, and will forward updates to the
    mapping function if the value is moved to another key.

    The mapping function should create a single VirtualInstance based on the
    current value and observable key for each value.
    
    This is useful for instances where the input observable is an "Array" "Map",
    or "Dictionary" type, and may perform better than
    [VirtualInstance:MapChildren] in that case by minimizing
    creation/destruction of virtual instances.

    Example:
    ```lua
    local function ItemList()
        local visibleItemIdSet = Dec.State({"Sword", "Gun", "MagicStaff"})
        local scrollingFrame = Dec.New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1)
        })
        scrollingFrame:MapChildrenByValue(visibleItemIds, function(id, i)
            return ItemCard({
                id = id,
                layoutOrder = i, -- Observable<number>
            })
        end)
        return scollingFrame
    end
    ```
]=]
function VirtualInstance.__index.MapChildrenByValue(
    self: VirtualInstance,
    input: Observable<any>,
    map: (key: any, value: Observable<any>) -> VirtualInstance?
)
    assertNotYetMounted(self)

    local reverseLookup = input:Map(function(currentInput)
        local transformed = {}
        for k, v in currentInput do
            transformed[v] = k
        end
        return transformed
    end)
    table.insert(self._directives, {
        _type = "MapChildrenByKey",
        _payload = {
            input = reverseLookup,
            map = map,
        },
        _trace = getTrace("VirtualInstance:MapChildrenByValue", 1),
    })
end


--[=[
    @method DestroyPremadeChildren
    @within VirtualInstance
    @param filter string | ((child: Instance) -> boolean) | nil

    Adds a directive to destroy children of the VirtualInstance once it is
    mounted.

    This is useful for scenarios where the design of a premade template contains
    objects that should be destroyed before rendering the actual UI.

    The "filter" argument can be a name or predicate describing which children
    to destroy. If a name is defined, all children found with this name will be
    destroyed. If a predicate is defined, all children for which this function
    returns true will be destroyed.
]=]
function VirtualInstance.__index.DestroyPremadeChildren(
    self: VirtualInstance,
    filter: string | ((child: Instance) -> boolean)?
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "DestroyPremadeChildren",
        _payload = filter,
        _trace = getTrace("VirtualInstance:DestroyPremadeChildren", 1),
    })
end

--[=[
    @method OnMount
    @within VirtualInstance
    @param callback () -> ()

    Adds a lifecycle callback to be called when the Virtual Instance is mounted.
    This is useful for performing a side effect that begins/ends when a
    component starts/stops being rendered.
]=]
function VirtualInstance.__index.OnMount(
    self: VirtualInstance,
    callback: () -> ()
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OnMount",
        _payload = callback,
        _trace = getTrace("Dec.OnMount", 1),
    })
end

--[=[
    @method OnUnmount
    @within VirtualInstance
    @param callback () -> ()

    Adds a lifecycle callback to be called when the Virtual Instance is
    unmounted.

    This is useful for performing a side effect that begins/ends when a
    component starts/stops being rendered.
]=]
function VirtualInstance.__index.OnUnmount(
    self: VirtualInstance,
    callback: () -> ()
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OnUnmount",
        _payload = callback,
        _trace = getTrace("Dec.OnUnmount", 1),
    })
end

--[=[
    @method FindChild
    @within VirtualInstance
    @param childPath string
    @return VirtualInstance

    Creates a new VirtualInstance that automatically mounts on the child of the
    parent VirtualInstance. Will wait until a child with the given name is
    found.

    The following blocks of code are equivalent:
    ```lua
    local parent = Dec.Premade("Frame")
    local child = Dec.Premade("Frame")
    parent:AddChild("ChildName", child)
    ```

    ```lua
    local parent = Dec.Premade("Frame")
    local child = parent:FindChild("ChildName")
    ```
]=]
function VirtualInstance.__index.FindChild(
    self: VirtualInstance,
    className: string,
    path: ChildPath
): VirtualInstance
    assertNotYetMounted(self)

    -- De-sugar argument
    local VirtualInstanceCreators = (require :: any)(
        script.Parent.VirtualInstanceCreators)

    local childVInst = VirtualInstanceCreators.Premade(className)
    self:AddChild(path, childVInst)
    
    return childVInst
end

--[=[
    @method Combine
    @within VirtualInstance
    @param ... VirtualInstance
    
    Combines the directives from another, or multiple other VirtualInstances.
    The VirtualInstances passed in must meet the following requirements:

    - They must be of "Premade" type, with an equivalent or related ClassName to
    the target VirtualInstance.
    - They must not already be rendered by Dec and/or combined with another
    VirtualInstance.

    Combine can be used to compose different effects or input handlers within a
    VirtualInstance tree:

    ```lua
    local function RecolorWithMouseInput()
        local isHovering = Dec.State(false)
        local isPressing = Dec.State(false)
        return Dec.Premade("GuiButton", {
            MouseEnter = function()
                isHovering:Set(true)
            end,
            MouseLeave = function()
                isHovering:Set(false)
            end,
            MouseButton1Down = function()
                isPressing:Set(true)
            end,
            MouseButton1Up = function()
                isPressing:Set(false)
            end,
            BackgroundColor3 = Dec.Map(isHovering, isPressing)(function(
                currentHovering,
                currentPressing
            )
                if currentPressing then
                    return Color3.fromHex("aaa")
                elseif currentHovering then
                    return Color3.fromHex("ddd")
                else
                    return Color3.fromHex("fff")
                end,
            end),
        })
    end

    -- . . .
    
    local function Button()
        local button = Dec.New("Button", {
            Activated = function()
                print("Button was clicked!")
            end,
            AutoButtonColor = false,
        })
        button:Combine(RecolorWithMouseInput())
        return button
    end
    ```
]=]
function VirtualInstance.__index.Combine(
    self: VirtualInstance,
    ...: VirtualInstance
)
    local args: {VirtualInstance} = {...}
    local _combinedIsAChecks = self._combinedIsAChecks :: {{
        className: string,
        trace: VirtualInstanceTrace?,
    }}
    if not _combinedIsAChecks then
        _combinedIsAChecks = {}
        self._combinedIsAChecks = _combinedIsAChecks
    end
    for _, arg: any in args do
        if arg._constructorType ~= "Premade" then
            error("Combined VirtualInstances must have a 'Premade' type!")
        end
        if table.isfrozen(arg._directives) then
            error("Attempt to pass a frozen VirtualInstance as an argument to "
                .. "VirtualInstance:Combine(). A VirtualInstance can only be "
                .. "combined if it has not already been mounted or combined "
                .. "before.")
        end
        table.freeze(arg._directives)

        table.insert(_combinedIsAChecks, {
            className = arg._constructorTypeArgument,
            trace = if #arg._directives == 0
                then nil
                else arg._directives[1]._trace
        })
        for _, directive in arg._directives do
            table.insert(self._directives, directive)
        end
    end
end



--[=[
    @method SubscribeWhileMounted
    @within VirtualInstance
    @param input: Observable<T>
    @param listener (value: T) -> ()
    @param immediatelyCallListenerOnMount boolean?

    Subscribes a custom listener to an observable's value while the
    VirtualInstance is mounted, and automatically unsubscribes the listener when
    the VirtualInstance unmounts.

    :::tip
    SubscribeWhileMounted is much safer than calling [Observable:Subscribe]
    directly, as you do not need to handle an unsubscribe function manually to
    prevent memory leaks.

    You can use this function to trigger side effects such as animations
    whenever an observable value changes:
    ```lua
    local function PulseAnimation(valueToWatch: Dec.Observable<any>)
        -- Create a UIScale object that plays a 1-second "pulse" animation
        -- whenever a stopwatch is played.
        local stopwatch = Dec.Stopwatch(1)
        local uiScale = Dec.New("UIScale", {
            Scale = stopwatch:Map(function(currentTime)
                return 1 + (0.5 - currentTime) * 0.1
            end)
        })

        -- Play the stopwatch whenever the valueToWatch observable changes.
        uiScale:SubscribeWhileMounted(valueToWatch, function()
            stopwatch:Start()
        end)

        return uiScale
    end
    ```
    :::
]=]
function VirtualInstance.__index.SubscribeWhileMounted(
    self: VirtualInstance,
    input: Observable<any>,
    listener: (value: any) -> (),
    immediatelyCallListenerOnMount: boolean?
): ()
    local unsubscribe: (() -> ())? = nil
    self:OnMount(function()
        unsubscribe = input:Subscribe(listener, immediatelyCallListenerOnMount)
    end)
    self:OnUnmount(function()
        if unsubscribe then
            unsubscribe()
        end
    end)
end

--[[
    @function new
    @within VirtualInstance
    @private
    @return VirtualInstance - A new, empty Virtual Instance.

    A mutable element that Dec reconciles into a Roblox Instance.
    When a VirtualInstance is reconciled, its properties are sealed. A
    VirtualInstance should only be mutated by component objects before it is
    reconciled. Use Observers instead to mutate a VirtualInstance after it has
    been reconciled.
]]
function VirtualInstance.new(
    constructorType: "New" | "Clone" | "Premade" | "Extract",
    constructorPayload: any?,
    defaultProperties: {[string]: any}?,
    defaultChildMap: ChildMap?,
    debugTraceLevel: number?
): VirtualInstance
    local traceLevel = (debugTraceLevel or 0) + 1

    local directives = {}
    if defaultProperties then
        table.insert(
            directives,
            {
                _type = "Properties",
                _payload = defaultProperties :: any,
                _trace = getTrace("Dec." .. constructorType, traceLevel)
            }
        )
    end
    if defaultChildMap then
        table.insert(
            directives,
            {
                _type = "Children",
                _payload = defaultChildMap,
                _trace = if #directives > 0
                    then directives[1]._trace
                    else getTrace("Dec." .. constructorType, traceLevel)
            }
        )
    end
    return setmetatable({
        _directives = directives,
        _constructorType = constructorType :: string,
        _constructorTypeArgument = constructorPayload :: any,
        _onReconciledNodeCallbacks =
            {} :: {[(Types.ReconciledNode) -> ()]: boolean},
    }, VirtualInstance :: any)
end

return VirtualInstance