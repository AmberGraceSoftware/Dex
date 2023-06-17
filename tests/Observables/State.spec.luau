--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Packages.Dec.Observables.State)

return function()
    it("should have a set-able value & notify changes to the value", function()
        local state = State.new(0)
        expect(state:Current()).to.equal(0)

        state:Set(5)
        expect(state:Current()).to.equal(5)

        local updateCount = 0
        state:Subscribe(function()
            updateCount += 1
        end)

        state:Set(10)
        expect(state:Current()).to.equal(10)
        expect(updateCount).to.equal(1)

        state:Set(10)
        expect(state:Current()).to.equal(10)
        expect(updateCount).to.equal(1)
    end)
end
