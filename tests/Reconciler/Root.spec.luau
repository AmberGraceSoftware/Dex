--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = require(ReplicatedStorage.Packages.Dec.Reconciler.Root)
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    it("should render and unmount a virtual instance", function()
        local hostInstance = Instance.new("Folder")
        local root = Root.new(hostInstance)

        local virtualInstance = Dec.New("Part")
        expect(root._reconciled).to.equal(nil)

        local reconciledNode = root:Render(virtualInstance)
        expect(root._reconciled).to.equal(reconciledNode)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(hostInstance:GetChildren()[1]).to.equal(node._instance)

        root:Unmount()
        expect(root._reconciled).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(0)
        hostInstance:Destroy()
    end)

    it("should destroy the root and its underlying instance", function()
        local hostInstance = Instance.new("Folder")
        local root = Root.new(hostInstance)

        local virtualInstance = Dec.New("Part")
        root:Render(virtualInstance)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(hostInstance:GetChildren()[1]).to.equal(node._instance)

        root:Destroy()
        expect(hostInstance.Parent).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(0)
        hostInstance:Destroy()
    end)
end
