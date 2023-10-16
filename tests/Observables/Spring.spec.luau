--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Spring = require(ReplicatedStorage.Packages.Dex.Observables.Spring)
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)
return function()
    it("should create a Spring which eases towards target", function()
        local target = State.new(0)
        local easingObservable = Spring.new(target)

        local function waitUntilClockChange()
            local start = os.clock()
            while os.clock() == start do end
        end

        expect(easingObservable).to.be.ok()
        target:Set(1)
        waitUntilClockChange()
        expect(easingObservable:Current() < 0.1).to.be.equal(true)
        expect(easingObservable:Current()).to.never.be.equal(0)
        target:Set(0.5)
        waitUntilClockChange()
        expect(easingObservable:Current() < 0.1).to.be.equal(true)
        expect(easingObservable:Current()).to.never.be.equal(0)
        easingObservable:ResetVelocity()
        target:Set(-100)
        local highestPoint = easingObservable:Current()
        waitUntilClockChange()
        expect(easingObservable:Current() < highestPoint).to.be.equal(true)
    end)
    
    it("should throw an error for unsupported data types", function()
        local target = State.new(true)
        expect(function()
            Spring.new(target)
        end).to.throw("Data type 'boolean' cannot be eased using Spring")
    end)
end
