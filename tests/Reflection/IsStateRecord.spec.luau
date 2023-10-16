--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)
local StateRecord = require(ReplicatedStorage.Packages.Dex.Observables.StateRecord)
local IsStateRecord = require(ReplicatedStorage.Packages.Dex.Reflection.IsStateRecord)

return function()
    it("returns true for StateRecord", function()
        local stateRecord = StateRecord.new({})
        expect(IsStateRecord(stateRecord)).to.equal(true)
    end)

    it("returns false for non-StateRecord values", function()
        expect(IsStateRecord(nil)).to.equal(false)
        expect(IsStateRecord(true)).to.equal(false)
        expect(IsStateRecord(42)).to.equal(false)
        expect(IsStateRecord("hello")).to.equal(false)
        expect(IsStateRecord({})).to.equal(false)
        expect(IsStateRecord(function() end)).to.equal(false)
        expect(IsStateRecord(State.new({}))).to.equal(false)
    end)
end
