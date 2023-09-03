--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)
return function()
    describe("OnMount", function()
        it("Calls a callback once immediately when a VirtualInstance mounts", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dec.Premade("Frame")
            local callCount = 0
            virtualInstance:OnMount(function()
                callCount += 1
            end)
            local root = Dec.Root(host)
            root:Render(virtualInstance)
            expect(callCount).to.equal(1)

            root:Unmount()
            expect(callCount).to.equal(1)
        end)
    end)
end
