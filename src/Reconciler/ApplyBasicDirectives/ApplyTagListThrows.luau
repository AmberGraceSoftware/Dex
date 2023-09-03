--!strict

local ChainedSubscribe = require(script.Parent.Parent.ChainedSubscribe)
local Types = require(script.Parent.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type Observable<T> = Types.Observable<T>

--[[
    Helper function which mounts a list of possibly observable tags.
]]
local function applyPossiblyObservableTagList(
    instance: Instance,
    tagList: {CanBeObservable<string?>}
): {
    getLastAppliedTagSet: () -> {[string]: any},
    cleanup: () -> (),
}
    if typeof(tagList) ~= "table" then
        return {
            getLastAppliedTagSet = function()
                return {}
            end,
            cleanup = function() end
        }
    end
    local unsubscribes = {}
    local tagToReferenceCount: {[string]: number} = {}
    for _, tag in tagList do
        if typeof(tag) == "string" then
            if not tagToReferenceCount[tag] then
                tagToReferenceCount[tag] = 1
                if not instance:HasTag(tag) then
                    instance:AddTag(tag)
                end
            else
                tagToReferenceCount[tag] += 1
            end
        elseif IsObservable(tag) then
            local lastTag = nil :: string?
            table.insert(unsubscribes, ChainedSubscribe(
                tag :: any,
                function(resolvedValue)
                    local nextTag = if typeof(resolvedValue) == "string"
                        then resolvedValue
                        else nil
                    if nextTag ~= lastTag then
                        if lastTag then
                            if tagToReferenceCount[lastTag] then
                                tagToReferenceCount[lastTag] -= 1
                                if tagToReferenceCount[lastTag] <= 0 then
                                    tagToReferenceCount[lastTag] = nil
                                    if instance:HasTag(lastTag) then
                                    instance:RemoveTag(lastTag) 
                                    end
                                end
                            end
                        end

                        if nextTag then
                            if not tagToReferenceCount[nextTag] then
                                tagToReferenceCount[nextTag] = 1
                                if not instance:HasTag(nextTag) then
                                    instance:AddTag(nextTag)
                                end
                            else
                                tagToReferenceCount[nextTag] += 1
                            end
                        end
                    end
                    lastTag = nextTag
                end
            ))
        end
    end

    return {
        cleanup = function()
            for _, unsub in unsubscribes do
                unsub()
            end
        end,
        getLastAppliedTagSet = function()
            return tagToReferenceCount
        end,
    }
end

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param tagList: CanBeObservable<{string}> - The tag list to apply to the VirtualInstance

    Applies a tag list to a VirtualInstance, throwing any Roblox engine
    errors encountered. If an error occurs, it should be logged to the console
    traced to the line of code where VirtualInstance:AddTags was called.
]]
local function ApplyTagListThrows(
    reconciledNode: Types.ReconciledNode,
    tagList: CanBeObservable<{string}>
)
    local instance = reconciledNode._instance :: Instance
    local reconciledUnsubs = reconciledNode._unsubscribes
    if IsObservable(tagList) then
        local lastApplyListReturn: {
            getLastAppliedTagSet: () -> ({[string]: any}),
            cleanup: () -> (),
        }? = nil
        local unsubscribe = ChainedSubscribe(
            tagList :: any,
            function(resolvedTagList)
                local lastTagSet: {[string]: any} = {}
                if lastApplyListReturn then
                    lastTagSet = lastApplyListReturn.getLastAppliedTagSet()
                    lastApplyListReturn.cleanup()
                end
                local nextApplyListReturn = applyPossiblyObservableTagList(
                    instance,
                    resolvedTagList
                )
                local nextTagSet = nextApplyListReturn.getLastAppliedTagSet()
                for tag in lastTagSet do
                    if nextTagSet[tag] then
                        continue
                    end
                    if instance:HasTag(tag) then
                        instance:RemoveTag(tag)
                    end
                end
                lastApplyListReturn = nextApplyListReturn
            end
        )
        table.insert(
            reconciledUnsubs,
            function()
                unsubscribe()
                if lastApplyListReturn then
                    lastApplyListReturn.cleanup()
                end
            end
        )
    else
        local applyListReturnValue = applyPossiblyObservableTagList(
            instance,
            tagList :: any
        )
        table.insert(
            reconciledUnsubs,
            applyListReturnValue.cleanup
        )
        table.insert(reconciledUnsubs, function()
            for tag in applyListReturnValue.getLastAppliedTagSet() do
                if instance:HasTag(tag) then
                    instance:RemoveTag(tag)
                end
            end
        end)
    end
end

return ApplyTagListThrows