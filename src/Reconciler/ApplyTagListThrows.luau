--!strict

local CollectionService = game:GetService("CollectionService")
local Types = require(script.Parent.Parent.Types)
local IsObservable = require(script.Parent.Parent.Reflection.IsObservable)
type Set<T> = Types.Set<T>
type CanBeObservable<T> = Types.CanBeObservable<T>
type Observable<T> = Types.Observable<T>

--[[
    @param reconciledNode: Dec.ReconciledNode - The reconciled node to store cleanup tasks on
    @param tagList: CanBeObservable<{string}> - The tag list to apply to the VirtualInstance
    @return void

    Applies a tag list to a VirtualInstance, throwing any Roblox engine
    errors encountered. If an error occurs, it should be logged to the console
    traced to the line of code where VirtualInstance:AddTags was called.
]]
local function ApplyTagListThrows(
    reconciledNode: Types.ReconciledNode,
    tagList: CanBeObservable<{string}>
)
    local instance = reconciledNode._instance
    local reconciledUnsubs = reconciledNode._unsubscribes
    if IsObservable(tagList) then
        local lastTagList: {string} = {}
        local function updateTagsThrows(currentTagList: {string})
            local currentTagSet: {[string]: true} = {}
            for _, tag in currentTagList do
                currentTagSet[tag] = true
            end

            for _, tag in lastTagList do
                if not currentTagSet[tag] then
                    CollectionService:RemoveTag(instance, tag)
                end
            end
            for _, tag in currentTagList do
                if not CollectionService:HasTag(instance, tag) then
                    CollectionService:AddTag(instance, tag)
                end
            end
            lastTagList = currentTagList
        end
        table.insert(
            reconciledUnsubs,
            (tagList :: Observable<{string}>):Subscribe(updateTagsThrows)
        )
        updateTagsThrows((tagList :: Observable<{string}>):Current())
    else
        for _, tag in tagList :: {string} do
            CollectionService:AddTag(instance, tag)
        end
    end
end

return ApplyTagListThrows