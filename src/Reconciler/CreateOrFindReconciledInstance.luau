--!strict
local Types = require(script.Parent.Parent.Types)
type VirtualInstance = Types.VirtualInstance

local WAIT_FOR_CHILD_TIMEOUT = 15

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
    local result: Instance? = nil
    local onResultCallbacks: {(Instance) -> ()} = {}

    local childAddedConn: RBXScriptConnection? = nil
    local cancelled = false
    if virtualInstance._constructorType == "New" then
        local newInstance = Instance.new(
            virtualInstance._constructorTypeArgument)
        newInstance.Name = childPath or "DecRoot"
        result = newInstance
    elseif virtualInstance._constructorType == "Clone" then
        local newInstance = virtualInstance._constructorTypeArgument:Clone()
        newInstance.Name = childPath or "DecRoot"
        result = newInstance
    else
        if childPath then
            local initialChild = hostInstance:FindFirstChild(childPath)
            if initialChild then
                result = initialChild
            else
                childAddedConn = hostInstance.ChildAdded:Connect(function(child)
                    if child.Name == childPath then
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
return CreateOrFindReconciledInstance