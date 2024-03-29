--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IntSpring = require(ReplicatedStorage.Packages.Dex.Observables.IntSpring)
local State = require(ReplicatedStorage.Packages.Dex.Observables.State)
return function()
    local function waitUntilClockChange()
        local start = os.clock()
        while os.clock() == start do end
    end

    it("constructs IntSpring which eases to target w/ int rounding", function()
        local target = State.new(0)
        local easingObservable = IntSpring.new(target)
        expect(easingObservable).to.be.ok()

        target:Set(1.1)
        waitUntilClockChange()
        expect(easingObservable:Current()).to.equal(0)
        expect(easingObservable:CurrentTarget()).to.equal(1)

        target:Set(2.6)
        waitUntilClockChange()
        expect(easingObservable:Current()).to.equal(0)
        expect(easingObservable:CurrentTarget()).to.equal(3)

        target:Set(-3.4)
        waitUntilClockChange()
        expect(easingObservable:Current()).to.equal(0)
        expect(easingObservable:CurrentTarget()).to.equal(-3)
    end)

    it("should throw an error for unsupported data types", function()
        local target = State.new(true)
        expect(function()
            IntSpring.new(target)
        end).to.throw("Data type 'boolean' cannot be eased using IntSpring")
    end)
end
