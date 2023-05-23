--!strict

local Types = require(script.Parent.Types)

export type Root = Types.Root

local Root = {}
Root.__index = {}
Root.__index._dectype = "Root"

function Root.__index.Render(
    self: Root,
    node: Types.VirtualInstance
): Types.ReconciledNode
    error("Not implemented yet")
end

function Root.__index.Unmount(self: Root)
    error("Not implemented yet")
end

function Root.__index.Destroy(self: Root)
    error("Not implemented yet")
end

function Root.new(instance: Instance): Root
    return setmetatable({
        _instance = instance,
        _reconciled = nil,
    }, Root)
end

return Root