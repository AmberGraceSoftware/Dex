--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)
return function()
    describe("OnUnmount", function()
        it("Calls a callback once immediately when a VirtualInstance unmounts", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dex.Premade("Frame")
            local callCount = 0
            virtualInstance:OnUnmount(function()
                callCount += 1
            end)
            local root = Dex.Root(host)
            root:Render(virtualInstance)
            expect(callCount).to.equal(0)

            root:Unmount()
            expect(callCount).to.equal(1)
        end)
    end)
end
