--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = require(ReplicatedStorage.Packages.Dec.Reconciler.Root)
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    it("should render then unmount a New virtual instance", function()
        local hostInstance = Instance.new("Folder")
        local root = Root.new(hostInstance)

        local virtualInstance = Dec.New("Part", {Transparency = 0.5})
        expect(root._reconciled).to.equal(nil)

        local reconciledNode = root:Render(virtualInstance)
        expect(root._reconciled).to.equal(reconciledNode)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(hostInstance:GetChildren()[1]).to.equal(node._instance)
        expect(node._instance.Transparency).to.equal(0.5)

        root:Unmount()
        expect(root._reconciled).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(0)
        hostInstance:Destroy()
    end)

    it("should destroy rendered instances when calling Destroy", function()
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

    it("should render then unmount a Premade virtual instance", function()
        local hostInstance = Instance.new("Folder")
        local existingInstance = Instance.new("Part")
        existingInstance.Name = "ExistingInstance"
        existingInstance.Parent = hostInstance

        local root = Root.new(hostInstance)

        local virtualInstance = Dec.Premade({
            Transparency = 0.5
        })
        expect(root._reconciled).to.equal(nil)

        local App = Dec.Premade({}, {
            ExistingInstance = virtualInstance
        })
        local reconciledNode = root:Render(App)
        expect(root._reconciled).to.equal(reconciledNode)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(hostInstance:GetChildren()[1]).to.equal(node._instance)
        expect(existingInstance.Transparency).to.equal(0.5)

        root:Unmount()
        expect(root._reconciled).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(1)
        expect(hostInstance:GetChildren()[1]).to.equal(existingInstance)
        expect(existingInstance.Transparency).to.equal(0.5)
        hostInstance:Destroy()
    end)

    it("should render then unmount a cloned virtual instance", function()
        local hostInstance = Instance.new("Folder")
        local templateInstance = Instance.new("Part")
        templateInstance.Name = "TemplateInstance"

        local root = Root.new(hostInstance)

        local virtualInstance = Dec.Clone(templateInstance, {
            Transparency = 0.5
        })
        expect(root._reconciled).to.equal(nil)

        local reconciledNode = root:Render(virtualInstance)
        expect(root._reconciled).to.equal(reconciledNode)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(node._instance.Name).to.equal("DecRoot")
        expect(node._instance.Transparency).to.equal(0.5)

        root:Unmount()
        expect(root._reconciled).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(0)
        hostInstance:Destroy()
    end)
end
