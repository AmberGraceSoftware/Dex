--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observable = require(ReplicatedStorage.Packages.Dex.Observables.Observable)
local IsObservable = require(ReplicatedStorage.Packages.Dex.Reflection.IsObservable)


return function()
    it("returns true for Observable", function()
        local observable = Observable.new(
            function()
                return 42
            end,
            function()
                return function() end
            end
        )
        expect(IsObservable(observable)).to.equal(true)
    end)

    it("returns false for non-Observable values", function()
        expect(IsObservable(nil)).to.equal(false)
        expect(IsObservable(true)).to.equal(false)
        expect(IsObservable(42)).to.equal(false)
        expect(IsObservable("hello")).to.equal(false)
        expect(IsObservable({})).to.equal(false)
        expect(IsObservable(function() end)).to.equal(false)
    end)
end
