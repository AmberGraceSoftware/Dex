--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmitTracedError = require(script.Parent.EmitTracedError)
local IsVirtualInstance = require(ReplicatedStorage.Packages.Dec.Reflection.IsVirtualInstance)
local Types = require(script.Parent.Parent.Types)
type VirtualInstance = Types.VirtualInstance

local WAIT_FOR_CHILD_TIMEOUT = 30
local DEFAULT_CREATED_CHILD_NAME = "DecRoot"

type PseudoPromise = {
    andThen: (callback: (Instance, number) -> ()) -> (),
    cancel: () -> (),
}

local function CreateNewReconciledInstance(
    childPath: string?,
    virtualInstance: VirtualInstance,
    debugLevel: number
): PseudoPromise
    debugLevel += 1
    local newInstance = Instance.new(virtualInstance._constructorTypeArgument)
    newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
    return {
        andThen = function(callback)
            callback(newInstance, debugLevel + 1)
        end,
        cancel = function() end,
    }
end

local function FindChildReconciledInstance(
    hostInstance: Instance,
    childPath: string?,
    debugLevel: number
): PseudoPromise
    debugLevel += 1
    local result: Instance? = nil
    local onResultCallbacks: {(Instance, debugLevel: number) -> ()} = {}
    local childAddedConn: RBXScriptConnection? = nil
    local cancelled = false
    if childPath then
        local initialChild = hostInstance:FindFirstChild(childPath)
        if initialChild then
            result = initialChild
        else
            childAddedConn = hostInstance.ChildAdded:Connect(function(child)
                if child.Name == childPath then
                    result = child
                    for _, cb in onResultCallbacks do
                        task.spawn(cb, child, debugLevel + 1)
                    end
                end
            end)
            task.delay(WAIT_FOR_CHILD_TIMEOUT, function()
                if cancelled then
                    return
                end
                warn(
                    "Timeout when attempting to mount premade " .. 
                    "VirtualInstance under " .. hostInstance:GetFullName()
                    .. ": No child was found named '" .. childPath .. "'"
                )
            end)
        end
    else
        result = hostInstance
    end
    return {
        andThen = function(callback)
            if result then
                callback(result, debugLevel + 1)
            else
                table.insert(onResultCallbacks, callback)
            end
        end,
        cancel = function()
            cancelled = true
            if childAddedConn then
                childAddedConn:Disconnect()
                childAddedConn = nil
            end
        end
    }
end

local function CloneTemplateReconciledInstance(
    childPath: string?,
    virtualInstance: VirtualInstance,
    debugLevel: number
): PseudoPromise
    debugLevel += 1
    local templateArg = virtualInstance._constructorTypeArgument
    if IsVirtualInstance(templateArg) then
        if templateArg._constructorType == "New" then
            -- In the case that our template was a "Dec.New" virtual
            -- instance, simply treat as a Dec.New call
            return CreateNewReconciledInstance(childPath, templateArg,
                debugLevel)
        elseif
            templateArg._reconciledNode
            and templateArg._reconciledNode._instance
        then
            -- In the case that the template is an already-mounted node,
            -- immediately clone it.
            local newInstance = templateArg:Clone()
            newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
            return {
                andThen = function(callback)
                    callback(newInstance, debugLevel + 1)
                end,
                cancel = function() end,
            }
        else
            -- In the case that we passed in a latent-mounted VirtualInstance,
            -- check if it has resolved into an instance this frame. If not,
            -- raise an exception.
            local result: Instance? = nil
            local onResultCallbacks: {(Instance, debugLevel: number) -> ()} = {}
            local cancelled = false
            task.defer(function()
                if cancelled then
                    return
                end
                local instance
                if templateArg._reconciledNode then
                    instance = templateArg._reconciledNode._instance
                end
                if not instance then
                    local firstEncounteredTrace = nil
                    for _, directive in virtualInstance._directives do
                        if directive._trace then
                            firstEncounteredTrace = directive._trace
                            break
                        end
                    end
                    if not firstEncounteredTrace then
                        for _, directive in templateArg._directives do
                            if directive._trace then
                                firstEncounteredTrace = directive._trace
                                break
                            end
                        end
                    end
                    EmitTracedError(
                        "Error when mounting cloned VirtualInstance: The " .. 
                        "provided template must be an Instance, or a " .. 
                        "VirtualInstance that has already been mounted or " .. 
                        "will be mounted within the same frame. Perhaps you " ..
                        "passed an unmounted VirtualInstance as a template " .. 
                        "for Dec.Clone()?",
                        firstEncounteredTrace,
                        1
                    )
                end
                result = instance
                for _, cb in onResultCallbacks do
                    task.spawn(cb, instance, 1)
                end
            end)
            return {
                andThen = function(callback)
                    if result then
                        callback(result, debugLevel + 1)
                    else
                        table.insert(onResultCallbacks, callback)
                    end
                end,
                cancel = function()
                    cancelled = true
                end,
            }
        end
    else
        -- In standard case, use template instance provided
        local newInstance = templateArg:Clone()
        newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
        return {
            andThen = function(callback)
                callback(newInstance, debugLevel + 1)
            end,
            cancel = function() end,
        }
    end
end

--[[
    @param hostInstance: Instance
    @param childPath: string?
    @param virtualInstance: VirtualInstance
    @return {
        andThen: (instance: Instance) -> (),
        cancel: () -> ()
    }

    Returns a cancellable promise-like object which resolves with the instance
    once created or found.
]]
local function CreateOrFindReconciledInstance(
    hostInstance: Instance,
    childPath: string?,
    virtualInstance: VirtualInstance,
    debugLevel: number
)
    debugLevel += 1

    if virtualInstance._constructorType == "New" then
        return CreateNewReconciledInstance(childPath, virtualInstance,
            debugLevel)
    elseif virtualInstance._constructorType == "Clone" then
        return CloneTemplateReconciledInstance(childPath, virtualInstance,
            debugLevel)
    else
        return FindChildReconciledInstance(hostInstance, childPath, debugLevel)
    end
end
return CreateOrFindReconciledInstance