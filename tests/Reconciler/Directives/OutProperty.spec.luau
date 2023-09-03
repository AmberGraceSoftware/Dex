--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)
return function()
    describe("OutProperty", function()
        it("Connects a listener to a rendered instance's property", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dec.Premade("Frame")
            virtualInstance:SetProperties({ Name = "Foo" })
            
            local nameObs = virtualInstance:OutProperty("Name", "Fighters")
            expect(nameObs:Current()).to.equal("Fighters")

            local root = Dec.Root(host)
            root:Render(virtualInstance)
            expect(nameObs:Current()).to.equal("Foo")
        
            host.Name = "Bar"
            expect(nameObs:Current()).to.equal("Bar")

            root:Unmount()
            host.Name = "Baz"
            expect(nameObs:Current()).to.equal("Bar")
        end)
        it("Connects a listener to an instance's initial (pre-mount) properties", function()
            local host = Instance.new("Frame")
            host.Name = "Foo" 
            local virtualInstance = Dec.Premade("Frame")
            virtualInstance:SetProperties({ Name = "Fighters" })
            
            local nameObs = virtualInstance:OutInitialProperty("Name", "Bar")
            expect(nameObs:Current()).to.equal("Bar")

            local root = Dec.Root(host)
            root:Render(virtualInstance)
            expect(nameObs:Current()).to.equal("Foo")

            root:Unmount()
            host.Name = "Baz"
            expect(nameObs:Current()).to.equal("Foo")
        end)
    end)
end