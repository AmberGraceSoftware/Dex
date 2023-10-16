--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Root = require(ReplicatedStorage.Packages.Dex.Reconciler.Root)
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    it("should render then unmount a New virtual instance", function()
        local hostInstance = Instance.new("Folder")
        local root = Root.new(hostInstance)

        local virtualInstance = Dex.New("Part", {Transparency = 0.5})
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

        local virtualInstance = Dex.New("Part")
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

        local virtualInstance = Dex.Premade("Part", {
            Transparency = 0.5
        })
        expect(root._reconciled).to.equal(nil)

        local App = Dex.Premade("Folder", {}, {
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

        local virtualInstance = Dex.Clone(templateInstance, {
            Transparency = 0.5
        })
        expect(root._reconciled).to.equal(nil)

        local reconciledNode = root:Render(virtualInstance)
        expect(root._reconciled).to.equal(reconciledNode)
        expect(#hostInstance:GetChildren()).to.equal(1)
        local node: any = virtualInstance._reconciledNode
        expect(node).to.be.ok()
        expect(node._instance.Name).to.equal("DexRoot")
        expect(node._instance.Transparency).to.equal(0.5)

        root:Unmount()
        expect(root._reconciled).to.equal(nil)
        expect(#hostInstance:GetChildren()).to.equal(0)
        hostInstance:Destroy()
    end)

    it("should render a cloned virtual instance from another virtual template", function()
        local host = Instance.new("Frame")
        local templateChild = Instance.new("TextLabel")
        templateChild.Name = "Template"
        templateChild.BackgroundTransparency = 0.5
        templateChild.Parent = host

        local parent = Dex.Premade("Frame")
        local child = parent:FindChild("TextLabel", "Template")
        parent:AddChild("Copy", Dex.Clone(child, {
            BackgroundTransparency = 1
        }))

        local root = Dex.Root(host)
        root:Render(parent)

        expect(#host:GetChildren()).to.equal(2)

        local renderedTemplate = host:FindFirstChild("Template") :: any
        expect(renderedTemplate).to.be.ok()
        expect(renderedTemplate.BackgroundTransparency).to.equal(0.5)

        local renderedCopy = host:FindFirstChild("Copy") :: any
        expect(renderedCopy).to.be.ok()
        expect(renderedCopy.BackgroundTransparency).to.equal(1)
        
        root:Unmount()
        
        expect(#host:GetChildren()).to.equal(1)
        expect(host:GetChildren()[1].Name).to.equal("Template")
    end)
end
