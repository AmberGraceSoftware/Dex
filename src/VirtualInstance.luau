--!strict

local Types = require(script.Parent.Types)
local State = require(script.Parent.Observables.State)

type VirtualInstanceTrace = Types.VirtualInstanceTrace
type VirtualInstance = Types.VirtualInstance
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type State<T> = Types.State<T>
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

local VirtualInstance = {}
VirtualInstance.__index = {}
VirtualInstance.__index._dectype = "VirtualInstance"

--[[
    @param propertyMap: {[string]: CanBeObservable<any>} - Property map to render
    @return void

    Adds properties to be rendered on the instance when it is reconciled.

    Multiple calls to this function will merge the provided property map with
    the existing one, prioritizing the later call.
]]
function VirtualInstance.__index.SetProperties(
    self: VirtualInstance,
    propertyMap: {[string]: CanBeObservable<any>}
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Properties",
        _payload = propertyMap,
        _trace = getTrace("VirtualInstance:SetProperties", 1),
    })
end

--[[
    @param attributeMap: {[string]: any} - Attribute map to render
    @return void

    Adds attributes to be rendered on the instance when it is reconciled.
    
    Multiple calls to this function will merge the provided attribute map with
    the existing one, prioritizing the latest calls.
]]
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

--[[
    @param tags: CanBeObservable<{string}> - CollectionService tags to render.
    @return void

    Adds tags to the Virtual Instance when it is reconciled. Multiple calls to
    this function will add extra tags to the VirtualInstance if they do not
    exist.
]]
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

--[[
    @param eventName: string - The name of the event to connect.
    @param listener: (...any) -> () - The function to be called when the event is fired.
    @return void

    Adds an event listener to the Virtual Instance, which will automatically
    be connected and disconnected as the VirtualInstance is reconciled.
]]
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

--[[
    @param propName: string - The name of the property to output.
    @param initialValue: T - The Observable's initial value before the virtual instance is reconciled
    @return Observable<T> - An observable with the same output type as initialValue.

    Creates an Observable object that updates to the current value of an
    property on the virtual instance once when it is mounted, and listens to
    updates on this property.

    Give initialValue a type annotation if initializing to nil
    (e.g. nil :: string?)
]]
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

--[[
    @param propName: string - The name of the property to output.
    @param initialValue: T - The Observable's initial value before the virtual instance is reconciled
    @return Observable<T> - An observable with the same output type as initialValue.

    Creates an Observable object that updates to the original value of an
    property on the virtual instance once when it is mounted. This is useful
    for referencing properties on a premade instance without hardcoding them in
    a Dec component.

    Give initialValue a type annotation if initializing to nil
    (e.g. nil :: string?)
]]
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

--[[
    @param attributeName: string - The name of the attribute to output.
    @param initialValue: T - The Observable's initial value before the virtual instance is reconciled
    @return Observable<T> - An observable with the same output type as initialValue.

    Creates an Observable object that updates to the current value of an
    attribute on the virtual instance once when it is mounted, and listens to
    updates on this attribute.

    Give initialValue a type annotation if initializing to nil
    (e.g. nil :: string?)
]]
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

--[[
    @param attributeName: string - The name of the attribute to output.
    @param initialValue: T - The Observable's initial value before the virtual instance is reconciled
    @return Observable<T> - An observable with the same output type as initialValue.

    Creates an Observable object that updates to the original value of an
    attribute on the virtual instance once when it is mounted. This is useful
    for referencing attributes on a premade instance without hardcoding them in
    a Dec component.

    Give initialValue a type annotation if initializing to nil
    (e.g. nil :: string?)
]]
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

--[[
    @param outState: State<Instance> | State<Instance?> - The state to output the instance to.
    @return void

    Outputs a reference to the reconciled instance to a Dec State object.
]]
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

--[[
    @return Dec.VirtualInstance - A copy of the Virtual Instance.

    Creates a shallow copy of the Virtual Instance.
]]
function VirtualInstance.__index.Copy(
    self: VirtualInstance
): VirtualInstance
    assertNotYetMounted(self)
    return setmetatable({
        _directives = table.clone(self._directives),
        _constructorType = self._constructorType,
        _constructorTypeArgument = self._constructorTypeArgument,
    }, VirtualInstance :: any)
end

--[[
    @return Dec.VirtualInstance - A deep copy of the VirtualInstance.

    Creates a deep copy of the VirtualInstance and all child VirtualInstances.
]]
function VirtualInstance.__index.DeepCopy(
    self: VirtualInstance
): VirtualInstance
    assertNotYetMounted(self)
    local copy = self:Copy()
    for _, directive in copy._directives do
        if directive._type == "Children" then
            for _, child in directive._payload do
                if child._dectype == "VirtualInstance" then
                    child = child:DeepCopy()
                end
            end
        end
    end
    return copy
end

--[[
    @param path: Dec.ChildPath - The path of the child to add. Can be a dot-separated string, a table of raw names, or a number.
    @param child: CanBeObservable<Instance | VirtualInstance?> - The child VirtualInstance or actual Instance to add.
    @return void

    Adds a child VirtualInstance node to this VirtualInstance.

    The path can be a dot-separated string, or an array of raw string names.

    If the child is an actual Instance, that instance will be reparanted to the
    virtual instance when reconciled, and destroyed when the VirtualInstances is
    unmounted.
    
    If the child is a VirtualInstance, it will be created or found depending on
    the type of VirtualInstance passed in.
]]
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


--[[
    @param childMap: CanBeObservable<{[Dec.ChildPath]: CanBeObservable<Instance | VirtualInstance?>}>
    @return void

    Adds multiple children to the VirtualInstance given a child map. See
    VirtualInstance:Child() for API reference
]]
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

--[[
    @param callback: (instance: Instance) -> () - The lifecycle callback
    @return void

    Adds a lifecycle callback to be called when the Virtual Instance is mounted.
]]
function VirtualInstance.__index.OnMount(
    self: VirtualInstance,
    callback: (instance: Instance) -> ()
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OnMount",
        _payload = callback,
        _trace = getTrace("Dec.OnMount", 1),
    })
end

--[[
    @param callback: (instance: Instance) -> () - The lifecycle callback
    @return void

    Adds a lifecycle callback to be called when the Virtual Instance is
    unmounted.
]]
function VirtualInstance.__index.OnUnmount(
    self: VirtualInstance,
    callback: (instance: Instance) -> ()
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OnUnmount",
        _payload = callback,
        _trace = getTrace("Dec.OnUnmount", 1),
    })
end

--[[
    @param nameOrPredicate: string | {string} - The name of the child to be extracted as a template
    @return Dec.VirtualInstance - A new VirtualInstance, cloned from a child of the parent instance
    Specifies that when the VirtualInstance is mounted, returns a new
    VirtualInstance which automatically mounts on the first child matching
    the name (or predicate) defined in the first argument to this method.
    
    Upon mount, all other children matching this name will be destroyed,
    and the template will be parented to `nil` by defalt. On unmount, it will be
    reparented to its original location if possible.

    Usage example:

```lua
local function CardListUI()
    -- Define a VirtualInstance to be mounted on pre-existing UI in PlayerGui
    local rootUI = Dec.Premade()

    -- Index a ScrollingFrame containing template cards
    local cardList = rootUI:FindChild("ScrollingFrame")

    -- Extract the first template named "CardTemplate", and destroy all other
    -- premade templates with that same name
    local cardTemplate = cardList:ExtractChildTemplate("CardTemplate")

    -- Generate 10 cards from the template
    local cards = {}
    for i = 1, 10 do
        table.insert(cards, Dec.Clone(cardTemplate, {
            LayoutOrder = i
        }))
    end

    return rootUI
end
```
]]
function VirtualInstance.__index.ExtractChildTemplate(
    self: VirtualInstance,
    childPath: ChildPath
): ()
    assertNotYetMounted(self)
    local childVInst = self:FindChild(childPath)
    local templateParent = nil
    childVInst:OnMount(function(instance)
        templateParent = instance.Parent
        instance.Parent = nil
    end)
    childVInst:OnUnmount(function(instance)
        pcall(function()
            instance.Parent = templateParent
        end)
    end)
    return childVInst
end

--[[
    @param childPath: string - The name of the child to find
    @return Dec.VirtualInstance - A new VirtualInstance representing the child of the parent VirtualInstance

    Creates a new VirtualInstance that automatically mounts on the child of the
    parent VirtualInstance. Will wait until a child with the given name is
    found.

    The following blocks of code are equivalent:
```lua
local parent = Dec.Premade()
local child = Dec.Premade()
parent:AddChild("ChildName", child)
```

```lua
local parent = Dec.Premade()
local child = parent:FindChild("ChildName")
```
]]
function VirtualInstance.__index.FindChild(
    self: VirtualInstance,
    path: ChildPath
): VirtualInstance
    assertNotYetMounted(self)

    -- De-sugar argument
    local VirtualInstanceCreators = (require :: any)(
        script.Parent.VirtualInstanceCreators)

    local childVInst = VirtualInstanceCreators.Premade()
    self:AddChild(path, childVInst)
    
    return childVInst
end

--[[
    @return Dec.VirtualInstance - A new, empty Virtual Instance.

    A mutable element that Dec reconciles into a Roblox Instance.
    When a VirtualInstance is reconciled, its properties are sealed. A
    VirtualInstance should only be mutated by componentt objects before it is
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
        _constructorTypeArgument = constructorPayload :: any
    }, VirtualInstance :: any)
end

return VirtualInstance