--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsVirtualInstance = require(ReplicatedStorage.Packages.Dex.Reflection.IsVirtualInstance)
local VirtualInstanceCreators = require(ReplicatedStorage.Packages.Dex.VirtualInstanceCreators)

return function()
    it("returns true for VirtualInstance", function()
        local virtualInstance = VirtualInstanceCreators.New("Part")
        expect(IsVirtualInstance(virtualInstance)).to.equal(true)
    end)

    it("returns false for non-VirtualInstance values", function()
        expect(IsVirtualInstance(nil)).to.equal(false)
        expect(IsVirtualInstance(true)).to.equal(false)
        expect(IsVirtualInstance(42)).to.equal(false)
        expect(IsVirtualInstance("hello")).to.equal(false)
        expect(IsVirtualInstance({})).to.equal(false)
        expect(IsVirtualInstance(function() end)).to.equal(false)
    end)
end
