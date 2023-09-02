--!strict

local ChainedSubscribe = require(script.Parent.Parent.ChainedSubscribe)
local Types = require(script.Parent.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type Observable<T> = Types.Observable<T>

local function applyPossiblyObservableTag(
    instance: Instance,
    tag: CanBeObservable<string?>
): (() -> ())?
    if IsObservable(tag) then
        local lastResolvedTag: string? = nil
        local unsubscribe = ChainedSubscribe(tag :: any, function(resolvedTag)
            if lastResolvedTag then
                if instance:HasTag(lastResolvedTag) then
                    instance:RemoveTag(lastResolvedTag)
                end
            end
            lastResolvedTag = if typeof(resolvedTag) == "string"
                then resolvedTag
                else nil
            if lastResolvedTag then
                if not instance:HasTag(lastResolvedTag) then
                    instance:AddTag(lastResolvedTag)
                end
            end
        end)
        return function()
            unsubscribe()
            if lastResolvedTag then
                if instance:HasTag(lastResolvedTag) then
                    instance:RemoveTag(lastResolvedTag)
                end
            end
        end
    elseif typeof(tag) == "string" then
        if not instance:HasTag(tag) then
            instance:AddTag(tag)
        end
        return function()
            if instance:HasTag(tag) then
                instance:RemoveTag(tag)
            end
        end
    end

    return nil
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
        local lastTagList: {string} = {}
        local lastTagSet: {[string]: true} = {}
        local lastTagCleanups: {[string]: () -> ()} = {}
        local function updateTagsThrows(currentTagList: {string})
            local currentTagSet: {[string]: true} = {}
            for _, tag in currentTagList do
                currentTagSet[tag] = true
            end

            local cleanupsToCall = {}
            for _, tag in lastTagList do
                if not currentTagSet[tag] then
                    cleanupsToCall[tag] = true
                end
            end
            for _, tag in currentTagList do
                if not lastTagSet[tag] then
                    cleanupsToCall[tag] = true
                end
            end
            for tag in cleanupsToCall do
                local cleanup = lastTagCleanups[tag]
                if cleanup then
                    cleanup()
                end
                lastTagCleanups[tag] = nil
            end
            for _, tag in currentTagList do
                lastTagCleanups[tag] = applyPossiblyObservableTag(
                    instance,
                    tag
                ) :: any
            end
            lastTagList = currentTagList
        end
        local unsubscribe = ChainedSubscribe(tagList :: any, updateTagsThrows)
        table.insert(
            reconciledUnsubs,
            function()
                unsubscribe()
                for _, cleanup in lastTagCleanups do
                    cleanup()
                end
            end
        )
    else
        for _, tag in tagList :: {string} do
            if not instance:HasTag(tag) then
                instance:AddTag(tag)
            end
        end
    end
end

return ApplyTagListThrows