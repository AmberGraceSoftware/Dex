--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    describe("AddChild", function()
        it("Adds a VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            vInst:AddChild("Foo", Dex.New("Frame"))

            Dex.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Foo")
        end)
        it("Adds a VirtualInstance child with numeric key", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")
            vInst:AddChild(1, Dex.New("Frame"))

            Dex.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
        end)
        it("Adds an observable VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")

            local childState = Dex.State(Dex.New("Frame"))
            vInst:AddChild(1, childState)

            Dex.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
            expect(host:GetChildren()[1].ClassName).to.equal("Frame")

            childState:Set(Dex.New("TextLabel", {Name = "Bar"}))
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Bar")
            expect(host:GetChildren()[1].ClassName).to.equal("TextLabel")
        end)
        it("Adds a nilable observable child", function()
            local host = Instance.new("Frame")
            local vInst = Dex.Premade("Frame")

            local childState = Dex.State(Dex.New("Frame") :: any)
            vInst:AddChild(1, childState)

            Dex.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
            expect(host:GetChildren()[1].ClassName).to.equal("Frame")

            childState:Set(nil)
            expect(#host:GetChildren()).to.equal(0)

            childState:Set(Dex.New("TextLabel", {Name = "Bar"}))
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Bar")
            expect(host:GetChildren()[1].ClassName).to.equal("TextLabel")

            childState:Set(Dex.Nil)
            expect(#host:GetChildren()).to.equal(0)
        end)
    end)
end
