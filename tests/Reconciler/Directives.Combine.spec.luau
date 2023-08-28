--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("Combine", function()
        it("Combines multiple premade VirtualInstances", function()
            local host = Instance.new("TextLabel")
            local vInst1 = Dec.Premade("TextLabel", {
                Text = "Foo",
            })
            local vInst2 = Dec.Premade("GuiObject", {}, {
                Child = Dec.New("Frame")
            })
            local vInst3 = Dec.Premade("GuiObject", {
                LayoutOrder = 123,
            })
            vInst1:Combine(
                vInst2,
                vInst3
            )

            Dec.Root(host):Render(vInst1)

            expect(table.isfrozen(vInst1._directives)).to.equal(true)
            expect(table.isfrozen(vInst2._directives)).to.equal(true)
            expect(table.isfrozen(vInst3._directives)).to.equal(true)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)
            expect(#host:GetChildren()).to.equal(1)
            expect(host:GetChildren()[1].Name).to.equal("Child")
        end)
    end)
end
