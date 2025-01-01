--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)
local FlattenObservable = require(ReplicatedStorage.Packages.Dex.Util.FlattenObservable)

return function()
    it("Flattens the example from the docs", function()
        local coins = State.new(State.new(3))
        local coinsFlattened = FlattenObservable(coins)
        expect(coinsFlattened:Current()).to.equal(3)
    
        coins:Set(State.new(5))
        expect(coinsFlattened:Current()).to.equal(5)
    
        coins:Current():Set(7)
        expect(coinsFlattened:Current()).to.equal(7)
    end)
    it("Flattens at depth 2", function()
        local coins = State.new(State.new(State.new(3)) :: any)
        local coinsFlattened = FlattenObservable(coins)
        local updatesCount = 0
        local lastUpdatedValue = coinsFlattened:Current()
        local unsub = coinsFlattened:Subscribe(function(newValue)
            updatesCount += 1
            lastUpdatedValue = newValue
        end)
        expect(coinsFlattened:Current()).to.equal(3)
        expect(updatesCount).to.equal(0)
        expect(lastUpdatedValue).to.equal(3)
    
        coins:Set(State.new(5))
        expect(coinsFlattened:Current()).to.equal(5)
        expect(updatesCount).to.equal(1)
        expect(lastUpdatedValue).to.equal(5)
    
        coins:Current():Set(7)
        expect(coinsFlattened:Current()).to.equal(7)
        expect(updatesCount).to.equal(2)
        expect(lastUpdatedValue).to.equal(7)
    
        coins:Current():Set(State.new(9))
        expect(coinsFlattened:Current()).to.equal(9)
        expect(updatesCount).to.equal(3)
        expect(lastUpdatedValue).to.equal(9)
        
        coins:Current():Current():Set(11)
        expect(coinsFlattened:Current()).to.equal(11)
        expect(updatesCount).to.equal(4)
        expect(lastUpdatedValue).to.equal(11)
        
        coins:Set(21)
        expect(coinsFlattened:Current()).to.equal(21)
        expect(updatesCount).to.equal(5)
        expect(lastUpdatedValue).to.equal(21)

        unsub()

        coins:Set(State.new(22))
        expect(coinsFlattened:Current()).to.equal(22)
        expect(updatesCount).to.equal(5)
        expect(lastUpdatedValue).to.equal(21)
    end)
end
