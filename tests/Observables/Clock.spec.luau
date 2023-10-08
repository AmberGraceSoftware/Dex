--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clock = require(ReplicatedStorage.Packages.Dec.Observables.Clock)

return function()
    it("Resolves to the current return value of os.time()", function()
        expect(Clock:Current()).to.equal(os.time())
    end)
end
