--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)

return function()
    describe("SetProperties", function()
        it("Sets static properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local virtualInstance = Dec.Premade("TextLabel", {
                Text = "Foo",
            })
            virtualInstance:SetProperties({
                LayoutOrder = 123,
            })
            Dec.Root(host):Render(virtualInstance)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)
        end)
        it("Sets observable properties on a VirtualInstance", function()
            local host = Instance.new("TextLabel")
            local textState = Dec.State("Foo")
            local layoutOrderState = Dec.State(123)

            local virtualInstance = Dec.Premade("TextLabel", {
                Text = textState,
            })
            virtualInstance:SetProperties({
                LayoutOrder = layoutOrderState,
            })
            Dec.Root(host):Render(virtualInstance)

            expect(host.Text).to.equal("Foo")
            expect(host.LayoutOrder).to.equal(123)

            textState:Set("Fighters")
            layoutOrderState:Set(456)

            expect(host.Text).to.equal("Fighters")
            expect(host.LayoutOrder).to.equal(456)
        end)
        it("Adds connections to a VirtualInstance", function()
            local host = Instance.new("TextLabel")

            local didChange = false
            local virtualInstance = Dec.Premade("TextLabel", {
                Changed = function()
                    didChange = true
                end
            })
            Dec.Root(host):Render(virtualInstance)

            expect(didChange).to.equal(false)

            host.Text = "Foo"
            expect(didChange).to.equal(true)
        end)
    end)
end
