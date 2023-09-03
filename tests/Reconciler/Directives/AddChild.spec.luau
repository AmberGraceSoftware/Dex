--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("AddChild", function()
        it("Adds a VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            vInst:AddChild("Foo", Dec.New("Frame"))

            Dec.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Foo")
        end)
        it("Adds a VirtualInstance child with numeric key", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")
            vInst:AddChild(1, Dec.New("Frame"))

            Dec.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
        end)
        it("Adds an observable VirtualInstance child", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")

            local childState = Dec.State(Dec.New("Frame"))
            vInst:AddChild(1, childState)

            Dec.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
            expect(host:GetChildren()[1].ClassName).to.equal("Frame")

            childState:Set(Dec.New("TextLabel", {Name = "Bar"}))
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Bar")
            expect(host:GetChildren()[1].ClassName).to.equal("TextLabel")
        end)
        it("Adds a nilable observable child", function()
            local host = Instance.new("Frame")
            local vInst = Dec.Premade("Frame")

            local childState = Dec.State(Dec.New("Frame") :: any)
            vInst:AddChild(1, childState)

            Dec.Root(host):Render(vInst)

            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("1")
            expect(host:GetChildren()[1].ClassName).to.equal("Frame")

            childState:Set(nil)
            expect(#host:GetChildren()).to.equal(0)

            childState:Set(Dec.New("TextLabel", {Name = "Bar"}))
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Bar")
            expect(host:GetChildren()[1].ClassName).to.equal("TextLabel")

            childState:Set(Dec.Nil)
            expect(#host:GetChildren()).to.equal(0)
        end)
    end)
end
