--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dex = require(ReplicatedStorage.Packages.Dex)
return function()
    describe("Connect", function()
        it("Connects and disconnects two listeners on mount/unmount", function()
            local host = Instance.new("TextLabel")
            
            local changedCount1 = 0
            local changedCount2 = 0
            local virtualInstance = Dex.Premade("TextLabel")
            virtualInstance:Connect("Changed", function()
                changedCount1 += 1
            end)
            virtualInstance:Connect("Changed", function()
                changedCount2 += 1
            end)
            local root = Dex.Root(host)
            root:Render(virtualInstance)
            expect(changedCount1).to.equal(0)
            expect(changedCount2).to.equal(0)
        
            host.Name = "Foo"
            expect(changedCount1).to.equal(1)
            expect(changedCount2).to.equal(1)

            root:Unmount()
            expect(changedCount1).to.equal(1)
            expect(changedCount2).to.equal(1)
        
            host.Name = "Fighters"
            expect(changedCount1).to.equal(1)
            expect(changedCount2).to.equal(1)
        end)
    end)
end