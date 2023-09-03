--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dec = require(ReplicatedStorage.Packages.Dec)
return function()
    describe("OutAttribute", function()
        it("Connects a listener to a rendered instance's attributes", function()
            local host = Instance.new("Frame")
            local virtualInstance = Dec.Premade("Frame")
            virtualInstance:SetAttributes({ Foo = 123 })
            
            local fooObs = virtualInstance:OutAttribute("Foo", 456)
            expect(fooObs:Current()).to.equal(456)

            local root = Dec.Root(host)
            root:Render(virtualInstance)
            expect(fooObs:Current()).to.equal(123)
        
            host:SetAttribute("Foo", 789)
            expect(fooObs:Current()).to.equal(789)

            root:Unmount()
            host:SetAttribute("Foo", 10_11_12)
            expect(fooObs:Current()).to.equal(789)
        end)
        it("Connects a listener to an instance's initial (pre-mount) attributes", function()
            local host = Instance.new("Frame")
            host:SetAttribute("Foo", 123)
            local virtualInstance = Dec.Premade("Frame")
            virtualInstance:SetAttributes({ Foo = 456 })
            
            local fooObs = virtualInstance:OutInitialAttribute("Foo", 789)
            expect(fooObs:Current()).to.equal(789)

            local root = Dec.Root(host)
            root:Render(virtualInstance)
            expect(fooObs:Current()).to.equal(123)

            root:Unmount()
            host:SetAttribute("Foo", 10_11_12)
            expect(fooObs:Current()).to.equal(123)
        end)
    end)
end