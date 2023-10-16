--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)

return function()
    describe("SetAttributes", function()
        it("Sets static attributes on a VirtualInstance", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dex.Premade("Frame")
            virtualInstance:SetAttributes({
                Foo = 123,
            })
            Dex.Root(host):Render(virtualInstance)
            expect(host:GetAttribute("Foo")).to.equal(123)
        end)
        it("Sets observable attributes on a VirtualInstance", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dex.Premade("Frame")
            local fooAttrState = Dex.State(123)
            virtualInstance:SetAttributes({
                Foo = fooAttrState
            })
            Dex.Root(host):Render(virtualInstance)
            expect(host:GetAttribute("Foo")).to.equal(123)

            fooAttrState:Set(456)
            expect(host:GetAttribute("Foo")).to.equal(456)
        end)
        it("Handles nil and Dex.Nil attributes", function()
            local host = Instance.new("Frame")
            host:SetAttribute("Fighters", 456)
            local virtualInstance = Dex.Premade("Frame")
            local fooAttrState = Dex.State(123 :: any)
            virtualInstance:SetAttributes({
                Foo = fooAttrState,
                Fighters = Dex.Nil,
            })
            Dex.Root(host):Render(virtualInstance)
            expect(host:GetAttribute("Foo")).to.equal(123)
            expect(host:GetAttribute("Fighters")).to.equal(nil)

            fooAttrState:Set(Dex.Nil)
            expect(host:GetAttribute("Foo")).to.equal(nil)
        end)
        -- If Instance attributes are ever supported:
        -- it("Sets reference to another VirtualInstance", function()
        --     local host = Instance.new("Frame")
        --     local refInst = Instance.new("Frame")
        --     refInst.Name = "Child"
        --     refInst.Parent = host

        --     local rootVInst = Dex.New("Frame")
        --     local refVInst = rootVInst:FindChild("Frame", "Child")
        --     rootVInst:SetAttributes({
        --         Child = refInst,
        --         Child2 = refVInst,
        --     })
        --     Dex.Root(host):Render(rootVInst)
        --     expect(host:GetAttribute("Child")).to.equal(refInst)
        --     expect(host:GetAttribute("Child2")).to.equal(refInst)
        -- end)
        it("Resolves nested observable attributes", function()
            local host = Instance.new("TextLabel")
            local fooState = Dex.State(123)
            local nestingState = Dex.State(fooState :: any)

            local virtualInstance = Dex.Premade("TextLabel", {})
            virtualInstance:SetAttributes({
                Foo = nestingState,
            })
            Dex.Root(host):Render(virtualInstance)
            expect(host:GetAttribute("Foo")).to.equal(123)

            fooState:Set(456)
            expect(host:GetAttribute("Foo")).to.equal(456)

            nestingState:Set(789)
            fooState:Set(10_11_12)
            expect(host:GetAttribute("Foo")).to.equal(789)

            nestingState:Set(fooState)
            expect(host:GetAttribute("Foo")).to.equal(10_11_12)
        end)
        it("Uses the last defined key when multiple directives are used", function()
            local host = Instance.new("TextLabel")
            local fooState1 = Dex.State(123)
            local fooState2 = Dex.State(456)

            local virtualInstance = Dex.Premade("TextLabel")
            virtualInstance:SetAttributes({Foo = fooState1})
            virtualInstance:SetAttributes({Foo = fooState2})
            Dex.Root(host):Render(virtualInstance)
            expect(host:GetAttribute("Foo")).to.equal(456)

            fooState1:Set(789)
            expect(host:GetAttribute("Foo")).to.equal(456)

            fooState2:Set(10_11_12)
            expect(host:GetAttribute("Foo")).to.equal(10_11_12)
        end)
    end)
end
