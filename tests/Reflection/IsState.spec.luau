--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)
local StateRecord = require(ReplicatedStorage.Packages.Dec.Observables.StateRecord)
local IsState = require(ReplicatedStorage.Packages.Dec.Reflection.IsState)

return function()
    it("returns true for State", function()
        local state = State.new(42)
        expect(IsState(state)).to.equal(true)
    end)

    it("returns false for non-State values", function()
        expect(IsState(nil)).to.equal(false)
        expect(IsState(true)).to.equal(false)
        expect(IsState(42)).to.equal(false)
        expect(IsState("hello")).to.equal(false)
        expect(IsState({})).to.equal(false)
        expect(IsState(function() end)).to.equal(false)
        expect(IsState(StateRecord.new({}))).to.equal(false)
    end)
end
