--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EmitTracedError = require(script.Parent.EmitTracedError)
local IsVirtualInstance = require(ReplicatedStorage.Packages.Dec.Reflection.IsVirtualInstance)
local Types = require(script.Parent.Parent.Types)
type VirtualInstance = Types.VirtualInstance
type VirtualInstanceTrace = Types.VirtualInstanceTrace
type ReconciledNode = Types.ReconciledNode

local WAIT_FOR_CHILD_TIMEOUT = 30
local DEFAULT_CREATED_CHILD_NAME = "DecRoot"

type PseudoPromise = {
    andThen: (callback: (Instance) -> ()) -> (),
    cancel: () -> (),
}

local function getFirstTrace(virtualInstance: VirtualInstance): VirtualInstanceTrace?
    for _, directive in virtualInstance._directives do
        if directive._trace then
            return directive._trace
        end
    end
    return nil
end

local function CreateNewReconciledInstance(
    childPath: string?,
    virtualInstance: VirtualInstance
): PseudoPromise
    local newInstance = Instance.new(virtualInstance._constructorTypeArgument)
    newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
    return {
        andThen = function(callback)
            callback(newInstance)
        end,
        cancel = function() end,
    }
end

local function findFirstChildOfNameAndClass(
    root: Instance,
    name: string,
    className: string
): Instance?
    local firstNameMatch = root:FindFirstChild(name)
    if firstNameMatch and firstNameMatch:IsA(className) then
        return firstNameMatch
    end
    for _, child in root:GetChildren() do
        if child.Name == name and child:IsA(className) then
            return child
        end
    end
    return nil
end

local function FindChildReconciledInstance(
    hostInstance: Instance,
    childClassName: string,
    childPath: string?,
    virtualInstance: VirtualInstance
): PseudoPromise
    local result: Instance? = nil
    local onResultCallbacks: {(Instance) -> ()} = {}
    local childAddedConn: RBXScriptConnection? = nil
    local cancelled = false
    if childPath then
        local initialChild = findFirstChildOfNameAndClass(hostInstance,
            childPath, childClassName)
        if initialChild then
            result = initialChild
        else
            childAddedConn = hostInstance.ChildAdded:Connect(function(child)
                if (child.Name == childPath) and child:IsA(childClassName) then
                    result = child
                    for _, cb in onResultCallbacks do
                        task.spawn(cb, child)
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
        if not hostInstance:IsA(childClassName) then
            EmitTracedError(
                "Instance ClassName mismatch when mounting root-level " .. 
                "premade instance of type '" .. childClassName .. "' on host" ..
                "instance of type '" .. hostInstance.ClassName .. "'",
                getFirstTrace(virtualInstance)
            )
        end
    end
    return {
        andThen = function(callback)
            if result then
                callback(result)
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

local function CloneLatentResolvedTemplate(
    childPath: string?,
    templateArg: VirtualInstance
): PseudoPromise
    local result: Instance? = nil
    local onResultCallbacks: {(Instance) -> ()} = {}
    
    local cancelled = false
    local cleanups = {}
    local function onTemplateInstance(templateInst: Instance)
        if cancelled then
            return
        end

        local newInstance = templateInst:Clone()
        newInstance.Name = childPath
            or DEFAULT_CREATED_CHILD_NAME
        result = newInstance
        for _, cb in onResultCallbacks do
            task.spawn(cb, newInstance)
        end
    end
    local function onTemplateNode(templateNode: ReconciledNode)
        if cancelled then
            return
        end
        if templateNode._instance then
            onTemplateInstance(templateNode._instance)
        else
            templateNode._instanceResolvedCallbacks[onTemplateInstance] = true
            table.insert(cleanups, function()
                templateNode._instanceResolvedCallbacks[onTemplateInstance]
                    = nil
            end)
        end
    end
    if templateArg._reconciledNode then
        onTemplateNode(templateArg._reconciledNode)
    else
        templateArg._onReconciledNodeCallbacks[onTemplateNode] = true
        table.insert(cleanups, function()
            templateArg._onReconciledNodeCallbacks[onTemplateNode] = nil
        end)
    end
    
    return {
        andThen = function(callback)
            if result then
                callback(result)
            else
                table.insert(onResultCallbacks, callback)
            end
        end,
        cancel = function()
            cancelled = true
            for _, cb in cleanups do
                cb()
            end
        end,
    }
end

local function CloneTemplateReconciledInstance(
    childPath: string?,
    virtualInstance: VirtualInstance
): PseudoPromise
    local templateArg = virtualInstance._constructorTypeArgument
    if IsVirtualInstance(templateArg) then
        if templateArg._constructorType == "New" then
            -- In the case that our template was a "Dec.New" virtual
            -- instance, simply treat as a Dec.New call
            return CreateNewReconciledInstance(childPath, templateArg)
        elseif
            templateArg._reconciledNode
            and templateArg._reconciledNode._instance
        then
            -- In the case that the template is an already-mounted node,
            -- immediately clone it.
            local newInstance = templateArg._reconciledNode._instance:Clone()
            newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
            return {
                andThen = function(callback)
                    callback(newInstance)
                end,
                cancel = function() end,
            }
        else
            -- In the case that we passed in a latent-mounted VirtualInstance,
            -- check if the template VInstance was mounted this frame and wait
            -- for the template at least to resolve. Otherwise, raise an
            -- exception.
            return CloneLatentResolvedTemplate(childPath, templateArg)
        end
    else
        -- In standard case, use template instance provided
        local newInstance = templateArg:Clone()
        newInstance.Name = childPath or DEFAULT_CREATED_CHILD_NAME
        return {
            andThen = function(callback)
                callback(newInstance)
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
    virtualInstance: VirtualInstance
): PseudoPromise
    if virtualInstance._constructorType == "New" then
        return CreateNewReconciledInstance(childPath, virtualInstance)
    elseif virtualInstance._constructorType == "Clone" then
        return CloneTemplateReconciledInstance(childPath, virtualInstance)
    else
        return FindChildReconciledInstance(
            hostInstance,
            virtualInstance._constructorTypeArgument,
            childPath,
            virtualInstance
        )
    end
end
return CreateOrFindReconciledInstance