--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetVirtualInstanceType = require(ReplicatedStorage.Packages.Dec.Reflection.GetVirtualInstanceType)
local VirtualInstanceCreators = require(ReplicatedStorage.Packages.Dec.VirtualInstanceCreators)

return function()
    it("returns the constructor type for New VirtualInstance", function()
        local virtualInstance = VirtualInstanceCreators.New("Part")
        local constructorType = GetVirtualInstanceType(virtualInstance)
        expect(constructorType).to.equal("New")
    end)

    it("returns the constructor type for Clone VirtualInstance", function()
        local virtualInstance = VirtualInstanceCreators.Clone(script)
        local constructorType = GetVirtualInstanceType(virtualInstance)
        expect(constructorType).to.equal("Clone")
    end)

    it("returns the constructor type for Premade VirtualInstance", function()
        local virtualInstance = VirtualInstanceCreators.Premade("Instance")
        local constructorType = GetVirtualInstanceType(virtualInstance)
        expect(constructorType).to.equal("Premade")
    end)

    it("throws an error for invalid argument type", function()
        local invalidValue: any = "not a VirtualInstance"
        local function testFunction()
            GetVirtualInstanceType(invalidValue)
        end
        expect(testFunction).to.throw()
    end)
end
