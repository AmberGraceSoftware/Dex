--!strict

local Types = require(script.Parent.Types)

type VirtualInstanceTrace = Types.VirtualInstanceTrace
type VirtualInstance = Types.VirtualInstance
type Observable<T> = Types.Observable<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type TweenState = Types.TweenState
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
            "VirtualInstance (See Dec docs).",
            2
        )
    end
end
local function parsePath(path: ChildPath): {string}
    if typeof(path) == "table" then
        local parsed = table.create(#path)
        for _, pathKey in path do
            if typeof(pathKey) == "string" then
                table.insert(parsed, pathKey)
            else
                table.insert(parsed, tostring(pathKey))
            end
        end
        return parsed
    elseif typeof(path) == "number" then
        return {tostring(path)}
    else
        return {path}
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
function VirtualInstance.__index.Properties(
    self: VirtualInstance,
    propertyMap: {[string]: CanBeObservable<any>}
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Properties",
        _payload = propertyMap,
        _trace = getTrace("Dec.Properties", 1),
    })
end

--[[
    @param TweenState: TweenState | {TweenState} - TweenState or TweenState list to render
    @return void

    Adds Dec.TweenState objects to play on the Virtual Instance. Multiple calls
    to this function will add TweenStates to this list.

    When played, tweens will override properties set using
    virtualInstance.Properties(), and will use Roblox Tween objects under the
    hood.
]]
function VirtualInstance.__index.Tweens(
    self: VirtualInstance,
    tweenStates: TweenState | {TweenState}
): ()
    assertNotYetMounted(self)
    local tweenList: {TweenState}
    if (tweenStates :: any)._dectype then
        tweenList = {tweenStates :: any}
    else
        tweenList = tweenStates :: any
    end
    table.insert(self._directives, {
        _type = "Tweens",
        _payload = tweenList,
        _trace = getTrace("Dec.Tweens", 1),
    })
end

--[[
    @param attributeMap: {[string]: any} - Attribute map to render
    @return void

    Adds attributes to be rendered on the instance when it is reconciled.
    
    Multiple calls to this function will merge the provided attribute map with
    the existing one, prioritizing the latest calls.
]]
function VirtualInstance.__index.Attributes(
    self: VirtualInstance,
    attributeMap: {[string]: CanBeObservable<any>}
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Tweens",
        _payload = attributeMap,
        _trace = getTrace("Dec.Attributes", 1),
    })
end

--[[
    @param tags: CanBeObservable<{string}> - CollectionService tags to render.
    @return void

    Adds tags to the Virtual Instance when it is reconciled. Multiple calls to
    this function will add extra tags to the VirtualInstance if they do not
    exist.
]]
function VirtualInstance.__index.Tags(
    self: VirtualInstance,
    tags: CanBeObservable<{string}>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Tags",
        _payload = tags,
        _trace = getTrace("Dec.Tags", 1),
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
        _trace = getTrace("Dec.Connect", 1),
    })
end

--[[
    @param propertyName: string - The name of the property to output.
    @param outState: State<any> - The state to output the property to.
    @return void

    Outputs a property from the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutProperty(
    self: VirtualInstance,
    propertyName: string,
    outState: State<any>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OutProperty",
        _payload = {
            property = propertyName,
            state = outState,
        },
        _trace = getTrace("Dec.OutProperty", 1),
    })
end

--[[
    @param propertyName: string - The name of the attribute to output.
    @param outState: State<any> - The state to output the attribute to.
    @return void

    Outputs an attribute from the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutAttribute(
    self: VirtualInstance,
    propertyName: string,
    outState: State<any>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OutAttribute",
        _payload = {
            attribute = propertyName,
            state = outState,
        },
        _trace = getTrace("Dec.OutAttribute", 1),
    })
end

--[[
    @param outState: State<Instance> | State<Instance?> - The state to output the instance to.
    @return void

    Outputs a reference to the reconciled instance to a Dec State object.
]]
function VirtualInstance.__index.OutInstance(
    self: VirtualInstance,
    outState: State<Instance> | State<Instance?>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "OutInstance",
        _payload = outState,
        _trace = getTrace("Dec.OutInstance", 1),
    })
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
    }, VirtualInstance)
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
        if directive._type == "Child" then
            if directive._payload._dectype == "VirtualInstance" then
                directive._payload.child = directive._payload.child:DeepCopy()
            end
        elseif directive._type == "Children" then
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
function VirtualInstance.__index.Child(
    self: VirtualInstance,
    path: ChildPath,
    child: CanBeObservable<Instance | VirtualInstance | nil>
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Child",
        _payload = {
            path = parsePath(path),
            child = child,
        },
        _trace = getTrace("Dec.Chlid", 1),
    })
end


--[[
    @param childMap: CanBeObservable<{[Dec.ChildPath]: CanBeObservable<Instance | VirtualInstance?>}>
    @return void

    Adds multiple children to the VirtualInstance given a child map. See
    VirtualInstance:Child() for API reference
]]
function VirtualInstance.__index.Children(
    self: VirtualInstance,
    childMap: ChildMap
): ()
    assertNotYetMounted(self)
    table.insert(self._directives, {
        _type = "Children",
        _payload = childMap,
        _trace = getTrace("Dec.Children", 1),
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
    @return Dec.VirtualInstance - A new, empty Virtual Instance.

    A mutable element that Dec reconciles into a Roblox Instance.
    When a VirtualInstance is reconciled, its properties are sealed. A
    VirtualInstance should only be mutated by componentt objects before it is
    reconciled. Use Observers instead to mutate a VirtualInstance after it has
    been reconciled.
]]
function VirtualInstance.new(
    constructorType: "New" | "Clone" | "Premade",
    constructorPayload: Instance | string?,
    defaultProperties: {[string]: CanBeObservable<any>}?,
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
        _constructorTypePayload = constructorPayload :: any
    }, VirtualInstance)
end

return VirtualInstance