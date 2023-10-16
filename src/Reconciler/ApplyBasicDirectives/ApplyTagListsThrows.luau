--!strict
local ChainedSubscribe = require(script.Parent.Parent.ChainedSubscribe)
local Types = require(script.Parent.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type Observable<T> = Types.Observable<T>
type ReconciledNode = Types.ReconciledNode

--[[
    Helper function which mounts a list of possibly observable tags.
]]
local function applyListOfPossiblyObservableTags(
    instance: Instance,
    tagList: {CanBeObservable<string?>},
    tagToReferenceCount: {[string]: number}
): (() -> (), {[string]: number})
    if typeof(tagList) ~= "table" then
        return function() end, {}
    end
    local unsubscribes = {}
    local innerStringToReferenceCount = {}
    for _, tag in tagList do
        if typeof(tag) == "string" then
            innerStringToReferenceCount[tag] =
                (innerStringToReferenceCount[tag] or 0) + 1
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
                            innerStringToReferenceCount[lastTag] -= 1
                            if innerStringToReferenceCount[lastTag] <= 0 then
                                innerStringToReferenceCount[lastTag] = nil
                            end
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
                            innerStringToReferenceCount[nextTag] =
                                (innerStringToReferenceCount[nextTag] or 0) + 1
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
    return function()
        for _, unsub in unsubscribes do
            unsub()
        end
    end, innerStringToReferenceCount
end

--[[
    @param reconciledNode: Dex.ReconciledNode - The reconciled node to store cleanup tasks on
    @param tagList: CanBeObservable<{string}> - The tag list to apply to the VirtualInstance

    Applies a tag list to a VirtualInstance, throwing any Roblox engine
    errors encountered. If an error occurs, it should be logged to the console
    traced to the line of code where VirtualInstance:AddTags was called.
]]
local function applyPossiblyObservableList(
    instance: Instance,
    tagList: CanBeObservable<{string}>,
    tagToReferenceCount: {[string]: number}
): () -> ()
    if IsObservable(tagList) then
        local lastCleanup: (() -> ())? = nil
        local lastInnerTagToReferenceCount: {[string]: number}? = nil
        local unsubscribe = ChainedSubscribe(
            tagList :: any,
            function(resolvedTagList)
                if lastCleanup then
                    lastCleanup()
                end

                -- Add new tag references for this list
                local nextCleanup, nextInnerTagToReferenceCount
                    = applyListOfPossiblyObservableTags(
                        instance,
                        resolvedTagList,
                        tagToReferenceCount
                    )
                
                -- Remove tag references for the old list
                if lastInnerTagToReferenceCount then
                    for tag, refCount in lastInnerTagToReferenceCount do
                        tagToReferenceCount[tag] -= refCount
                        if tagToReferenceCount[tag] <= 0 then
                            tagToReferenceCount[tag] = nil
                            if instance:HasTag(tag) then
                                instance:RemoveTag(tag)
                            end
                        end
                    end
                end

                lastCleanup = nextCleanup
                lastInnerTagToReferenceCount = nextInnerTagToReferenceCount
            end
        )
        return function()
            unsubscribe()
            if lastCleanup then
                lastCleanup()
            end
        end
    else
        return (applyListOfPossiblyObservableTags(
            instance,
            tagList :: any,
            tagToReferenceCount
        ))
    end
end

local function ApplyTagListsThrows(
    node: ReconciledNode,
    directives: {{_payload: CanBeObservable<{string}>}}
)
    local tagToReferenceCount: {[string]: number} = {}
    local instance = node._instance :: Instance
    for _, directive in directives do
        table.insert(node._unsubscribes, applyPossiblyObservableList(
            instance,
            directive._payload,
            tagToReferenceCount
        ))
    end
    table.insert(node._unsubscribes, function()
        for tag in tagToReferenceCount do
            if instance:HasTag(tag) then
                instance:RemoveTag(tag)
            end
        end
    end)
end

return ApplyTagListsThrows