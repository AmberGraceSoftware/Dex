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
    end)
end
