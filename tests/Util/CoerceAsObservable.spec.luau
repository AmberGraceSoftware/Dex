--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Packages.Dex.Observables.Observable)
local CoerceAsObservable = require(ReplicatedStorage.Packages.Dex.Util.CoerceAsObservable)

return function()
    it("returns the same Observable if passed an Observable", function()
        local observable = Observable.new(
            function()
                return 2
            end,
            function()
                return function() end
            end
        )
        local result = CoerceAsObservable(observable)
        expect(result).to.equal(observable)
    end)

    it("returns a new Observable if passed a non-Observable value", function()
        local value = "test"
        local result = CoerceAsObservable(value)
        expect(result).to.be.a("table")
        expect(result._dectype).to.equal("Observable")
        expect(result:Current()).to.equal("test")
    end)
end
