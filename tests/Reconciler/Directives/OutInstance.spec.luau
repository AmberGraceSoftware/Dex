--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)
return function()
    describe("OutInstance", function()
        it("Connects a listener to a rendered instance", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dex.Premade("Frame")
            
            local instObs = virtualInstance:OutInstance()
            expect(instObs:Current()).to.equal(nil)

            local root = Dex.Root(host)
            root:Render(virtualInstance)
            expect(instObs:Current()).to.equal(host)

            root:Unmount()
            expect(instObs:Current()).to.equal(host)
        end)
    end)
end